class SpendAgreement < ActiveRecord::Base
	include PgSearch
  acts_as_paranoid

  belongs_to :holding_company
  belongs_to :company

  has_one :spend_agreement_custom_field

  has_many :activities
  has_many :spend_agreement_deals, dependent: :destroy
  has_many :spend_agreement_clients, dependent: :destroy
  has_many :spend_agreement_contacts, dependent: :destroy
  has_many :spend_agreement_publishers, dependent: :destroy
  has_many :spend_agreement_parent_companies, dependent: :destroy
  has_many :spend_agreement_team_members, dependent: :destroy

  has_many :clients, through: :spend_agreement_clients
  has_many :contacts, through: :spend_agreement_contacts
  has_many :deals, through: :spend_agreement_deals
  has_many :ios, through: :deals
  has_many :publishers, through: :spend_agreement_publishers
  has_many :parent_companies, through: :spend_agreement_parent_companies, source: :parent_company
  has_many :users, through: :spend_agreement_team_members

  has_many :values, as: :subject

  validates_presence_of :name, :start_date, :end_date

  accepts_nested_attributes_for(
    :spend_agreement_publishers,
    :spend_agreement_parent_companies,
    allow_destroy: true
  )

  accepts_nested_attributes_for(
    :spend_agreement_deals,
    :spend_agreement_team_members,
    :values
  )

  before_save :set_values
  after_save :manage_related_records, on: [:create, :update]
  after_save :update_tracking, on: [:create, :update]
  after_save :build_agreements_info_message

  scope :for_clients, -> (client_ids) do
    joins(:spend_agreement_clients).where(spend_agreement_clients: {client_id: client_ids})
  end

  scope :for_time_period, -> (start_date, end_date) do
    where('start_date <= ? AND end_date >= ?', end_date, start_date) if start_date.present? && end_date.present?
  end

  scope :by_client_id, -> (id) { where('spend_agreement_clients.client_id = ?', id) if id.present? }

  scope :fuzzy_search, -> term { search_by_name(term) if term.present? }

  scope :by_holding_company, -> (id) do
    where(holding_company_id: [id, nil])
  end

  pg_search_scope :search_by_name, {
    against: :name,
    using: {
      tsearch: {
        prefix: true,
        any_word: true
      },
      dmetaphone: {
        any_word: true
      }
    },
    ranked_by: ':trigram'
  }

  attr_accessor :client_ids,
                :parent_companies_ids,
                :publishers_ids,
                :deals_before_track,
                :deals_after_track,
                :info_messages

  def value_from_field(field_id)
    values.find{ |val| val.field_id == field_id }&.option&.name
  end

  def info_messages
    @info_messages ||= []
  end

  def advertisers
    clients.by_type_id(Client.advertiser_type_id(company))
  end

  def agencies
    clients.by_type_id(Client.agency_type_id(company))
  end

  def all_brands
    if advertisers.ids.present?
      advertisers.ids
    else
      result = Client.where(company_id: company_id).where(parent_client_id: parent_companies.ids).ids
      return result if result.present?
      parent_companies.ids
    end
  end

  def all_agencies
    if agencies.ids.present?
      agencies.ids
    elsif holding_company_id.present?
      result = Client.where(company_id: company_id).where(holding_company_id: holding_company_id).ids
      if result.present?
        result
      else
        0
      end
    end
  end

  private

  def set_values
    self.type_id = values.find{ |val| val.field_id == type_field.id }&.option_id
    self.status_id = values.find{ |val| val.field_id == status_field.id }&.option_id
  end

  def type_field
    @type_field ||= company.fields.find_by(subject_type: 'Multiple', name: 'Spend Agreement Type')
  end

  def status_field
    @status_field ||= company.fields.find_by(subject_type: 'Multiple', name: 'Spend Agreement Status')
  end

  def manage_related_records
    prepare_params
    clear_related_items
    assign_new_related_items
    unlink_removed_items
  end

  def prepare_params
    [client_ids, parent_companies_ids, publishers_ids].compact.each do |list|
      list.to_a.map!(&:to_i)
    end
  end

  def clear_related_items
    spend_agreement_clients.clear if client_ids&.empty?
    spend_agreement_parent_companies.clear if parent_companies_ids&.empty?
    spend_agreement_publishers.clear if publishers_ids&.empty?
  end

  def assign_new_related_items
    client_ids_for_create.each do |client_id|
      spend_agreement_clients.create(client_id: client_id)
    end

    parent_companies_for_create.each do |id|
      spend_agreement_parent_companies.create(client_id: id)
    end

    publishers_for_create.each do |id|
      spend_agreement_publishers.create(publisher_id: id)
    end
  end

  def unlink_removed_items
    spend_agreement_clients.by_child_ids(clients_ids_for_destroy).destroy_all
    spend_agreement_parent_companies.by_child_ids(parent_companies_ids_for_destroy).destroy_all
    spend_agreement_publishers.by_child_ids(publishers_ids_for_destroy).destroy_all
  end

  def build_agreements_info_message
    message = SpendAgreements::InfoMessageBuilder.new(before_track: self.deals_before_track,
                                                      after_track: self.deals_after_track,
                                                      message_context: :agreement).perform
    self.info_messages << message if message
  end

  def update_tracking
    self.deals_before_track = self.deals.pluck_to_hash(:id, :name)
    SpendAgreementTrackingService.new(spend_agreement: self).track_deals
    self.deals_after_track = self.deals.pluck_to_hash(:id, :name)
  end

  def clients_intersection_ids
    client_ids.to_a & existing_client_ids
  end

  def parent_companies_intersection_ids
    parent_companies_ids.to_a & existing_parent_companies_ids
  end

  def publishers_intersection_ids
    publishers_ids.to_a & existing_publishers_ids
  end

  def client_ids_for_create
    client_ids.to_a - clients_intersection_ids
  end

  def parent_companies_for_create
    parent_companies_ids.to_a - parent_companies_intersection_ids
  end

  def publishers_for_create
    publishers_ids.to_a - publishers_intersection_ids
  end

  def clients_ids_for_destroy
    existing_client_ids - clients_intersection_ids
  end

  def parent_companies_ids_for_destroy
    existing_parent_companies_ids - parent_companies_intersection_ids
  end

  def publishers_ids_for_destroy
    existing_publishers_ids - publishers_intersection_ids
  end

  def existing_client_ids
    spend_agreement_clients.pluck(:client_id)
  end

  def existing_parent_companies_ids
    spend_agreement_parent_companies.pluck(:client_id)
  end

  def existing_publishers_ids
    spend_agreement_publishers.pluck(:publisher_id)
  end
end
