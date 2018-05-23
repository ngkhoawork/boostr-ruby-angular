class Client < ActiveRecord::Base
  SAFE_COLUMNS = %i{name}

  include PgSearch
  acts_as_paranoid

  belongs_to :company
  belongs_to :parent_client, class_name: 'Client'

  has_many :spend_agreement_clients
  has_many :spend_agreements, through: :spend_agreement_clients

  has_many :child_clients, class_name: 'Client', foreign_key: :parent_client_id
  has_many :client_members
  has_many :users, through: :client_members
  has_many :client_member_info, -> { joins(:user).select(:id, :client_id, :share, 'users.first_name', 'users.last_name') }, class_name: 'ClientMember'
  has_many :contacts, -> { uniq }, through: :client_contacts
  has_many :primary_client_contacts, -> { where('client_contacts.primary = ?', true) }, class_name: 'ClientContact'
  has_many :primary_contacts, -> { uniq }, through: :primary_client_contacts, source: :contact
  has_many :secondary_client_contacts, -> { where('client_contacts.primary = ?', false) }, class_name: 'ClientContact'
  has_many :secondary_contacts, -> { uniq }, through: :secondary_client_contacts, source: :contact
  has_many :client_contacts, dependent: :destroy
  has_many :revenues
  has_many :agency_deals, class_name: 'Deal', foreign_key: 'agency_id', dependent: :nullify
  has_many :advertiser_deals, class_name: 'Deal', foreign_key: 'advertiser_id', dependent: :nullify
  has_many :open_advertiser_deals, -> { joins(:stage).where('stages.open IS true') }, class_name: 'Deal', foreign_key: 'advertiser_id'

  has_many :agency_ios, class_name: 'Io', foreign_key: 'agency_id'
  has_many :advertiser_ios, class_name: 'Io', foreign_key: 'advertiser_id'
  has_many :bp_estimates

  has_many :agency_connections, class_name: :ClientConnection,
           foreign_key: :agency_id, dependent: :destroy
  has_many :advertiser_connections, class_name: :ClientConnection,
           foreign_key: :advertiser_id, dependent: :destroy
  has_many :agencies, -> { uniq }, through: :advertiser_connections, source: :agency
  has_many :advertisers, -> { uniq }, through: :agency_connections, source: :advertiser

  has_many :agency_client_contacts, through: :agencies, source: :client_contacts
  has_many :advertiser_client_contacts, -> { uniq }, through: :advertisers, source: :primary_client_contacts

  has_many :agency_contacts, through: :agencies, source: :contacts
  has_many :advertiser_contacts, -> { uniq }, through: :advertisers, source: :primary_contacts

  has_many :advertiser_contracts, class_name: 'Contract', foreign_key: :advertiser_id, dependent: :nullify
  has_many :agency_contracts, class_name: 'Contract', foreign_key: :agency_id, dependent: :nullify

  has_many :values, as: :subject
  has_many :activities, -> { order(happened_at: :desc) }
  has_many :agency_activities, -> { order(happened_at: :desc) }, class_name: 'Activity', foreign_key: 'agency_id'
  has_many :reminders, as: :remindable, dependent: :destroy
  has_many :account_dimensions, foreign_key: 'id', dependent: :destroy
  has_many :integrations, as: :integratable
  has_many :leads

  has_many :ssp_advertisers

  has_one :latest_advertiser_activity, -> { self.select_values = ["DISTINCT ON(activities.client_id) activities.*"]
    order('activities.client_id', 'activities.happened_at DESC')
  }, class_name: 'Activity'
  has_one :latest_agency_activity, -> { self.select_values = ["DISTINCT ON(activities.agency_id) activities.*"]
    order('activities.agency_id', 'activities.happened_at DESC')
  }, class_name: 'Activity'

  has_one :account_cf, dependent: :destroy, inverse_of: :client
  has_one :primary_client_member, -> { order(share: :desc) }, class_name: 'ClientMember'
  has_one :primary_user, through: :primary_client_member, source: :user
  has_one :address, as: :addressable
  has_one :publisher
  has_one :egnyte_folder, as: :subject

  belongs_to :client_category, class_name: 'Option', foreign_key: 'client_category_id'
  belongs_to :client_subcategory, class_name: 'Option', foreign_key: 'client_subcategory_id'
  belongs_to :client_region, class_name: 'Option', foreign_key: 'client_region_id'
  belongs_to :client_segment, class_name: 'Option', foreign_key: 'client_segment_id'
  belongs_to :holding_company

  delegate :street1, :street2, :city, :state, :zip, :phone, :country, to: :address, allow_nil: true
  delegate :name, to: :client_category, prefix: :category, allow_nil: true
  delegate :name, to: :parent_client, prefix: true, allow_nil: true
  delegate :name, to: :client_type, prefix: true, allow_nil: true

  accepts_nested_attributes_for :address, :values
  accepts_nested_attributes_for :account_cf

  validates :name, :client_type_id, presence: true
  validate  :base_fields_presence

  before_create :ensure_client_member
  after_commit :update_account_dimension, on: [:create, :update]

  after_commit :setup_egnyte_folders, on: [:create]
  after_commit :update_egnyte_folder, on: [:update]

  scope :by_type_id, -> type_id { where(client_type_id: type_id) if type_id.present? }
  scope :opposite_type_id, -> type_id { where.not(client_type_id: type_id) if type_id.present? }
  scope :exclude_ids, -> ids { where.not(id: ids) if ids.present? }
  scope :by_contact_ids, -> ids { Client.joins("INNER JOIN client_contacts ON clients.id=client_contacts.client_id").where("client_contacts.contact_id in (:q)", {q: ids}).order(:name).distinct }
  scope :by_category, -> category_id { where(client_category_id: category_id) if category_id.present? }
  scope :by_subcategory, -> subcategory_id { where(client_subcategory_id: subcategory_id) if subcategory_id.present? }
  scope :by_region, -> region_id { where(client_region_id: region_id) if region_id.present? }
  scope :by_segment, -> segment_id { where(client_segment_id: segment_id) if segment_id.present? }
  scope :by_name, -> name { where('clients.name ilike ?', "%#{name}%") if name.present? }
  scope :by_name_and_type_with_limit, -> (name, type) { by_name(name).by_type_id(type).limit(20) }
  scope :by_city, -> city { Client.joins("INNER JOIN addresses ON clients.id = addresses.addressable_id AND addresses.addressable_type = 'Client'").where("addresses.city = ?", city) if city.present? }
  scope :by_ids, -> ids { where(id: ids) if ids.present?}
  scope :by_last_touch, -> (start_date, end_date) { Client.joins("INNER JOIN (select client_id, max(happened_at) as last_touch from activities group by client_id) as tb1 ON clients.id = tb1.client_id").where("tb1.last_touch >= ? and tb1.last_touch <= ?", start_date, end_date) if start_date.present? && end_date.present? }
  scope :excepting_client_associations, ->(client, assoc_name) do
    send("without_#{assoc_name}_for", client) if %i(child_clients connections).include?(assoc_name.to_sym)
  end
  scope :without_child_clients_for, ->(client) { where.not(id: client.child_client_ids) }
  scope :without_connections_for, ->(client) { where.not(id: client.connection_entry_ids) }
  scope :without_related_clients, -> contact_id do
    where.not(id: ClientContact.where(contact_id: contact_id).pluck(:client_id))
  end
  scope :by_parent_clients, -> ids { where(parent_client_id: ids) if ids.present? }
  scope :fuzzy_find, -> term { fuzzy_search(term) if term.present? }
  scope :parent_ids, -> { where.not(parent_client_id: nil).distinct.pluck(:parent_client_id) }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      dictionary: :english,
                      prefix: true,
                      any_word: true
                    },
                    dmetaphone: {
                      any_word: true
                    }
                  },
                  ranked_by: ':trigram'
  
  pg_search_scope :fuzzy_search, {
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

  pg_search_scope :fuzzy_name_string_search,
                  against: :name,
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }

  ADVERTISER = 10
  AGENCY = 11

  def self.to_csv(company)
    Csv::AccountsService.new(self, company).perform
  end

  def connection_entry_ids
    case client_type.name
    when 'Agency'
      agency_connections.pluck(:advertiser_id)
    when 'Advertiser'
      advertiser_connections.pluck(:agency_id)
    else
      raise "callable for ['Advertiser', 'Agency'] clients only"
    end
  end

  def update_account_dimension
    AccountDimensionUpdaterService.new(client: self).perform
  end

  def advertiser?
    is_advertiser = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Advertiser"
        is_advertiser = true
        break
      end
    end
    is_advertiser
  end

  def agency?
    is_agency = false
    values.each do |value|
      if value.field.name == "Client Type" and value.option.name == "Agency"
        is_agency = true
        break
      end
    end
    is_agency
  end

  def max_share_user
    users.merge(ClientMember.ordered_by_share_desc).first
  end

  def deals_count
    advertiser_deals_count + agency_deals_count
  end

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def formatted_name
    f_name = name
    if !address.nil?
      if !address.city.nil?
        f_name = f_name + ', '+ address.city.to_s
      end
      if !address.state.nil?
        f_name = f_name + ', '+ address.state.to_s
      end
    end
    f_name
  end

  def as_json(options = {})
    if options[:override]
      super(options)
    else
      super(options.deep_merge(
        include: {
          address: {},
          parent_client: { only: [:id, :name] },
          account_cf: {},
          holding_company: {},
          values: {
            methods: [:value],
            include: [:option]
          },
          client_members: {
                  include: {
                          user: {
                                  only: [:id],
                                  methods: [:name]
                          }
                  },
                  only: [:id, :share, :user_id, :role]
          },
          activities: {
            include: {
              creator: {},
              client: { only: [:id, :name] },
              agency: { only: [:id, :name] },
              deal: { only: [:id, :name] },
              publisher: { only: [:id, :name] },
              contacts: {},
              custom_field: { only: CustomField.allowed_attr_names(company, 'Activity') },
              assets: {
                methods: [
                  :presigned_url
                ]
              },
              activity_type: { only: [:id, :name, :css_class, :action] }
            }
          },
          agency_activities: {
            include: {
              creator: {},
              contacts: {},
              custom_field: { only: CustomField.allowed_attr_names(company, 'Activity') },
              client: { only: [:id, :name] },
              agency: { only: [:id, :name] },
              deal: { only: [:id, :name] },
              publisher: { only: [:id, :name] },
              assets: {
                methods: [
                  :presigned_url
                ]
              },
              activity_type: { only: [:id, :name, :css_class, :action] }
            }
          },
          ssp_advertisers: {
            include: {
              ssp: {}
            }
          }
        },
        methods: [:deals_count, :fields, :formatted_name, :client_type_name]
      ).except(:override))
    end
  end

  def ensure_client_member
    return true if created_by.blank?
    return true if client_members.detect { |member| member.user_id == created_by }

    share = 0
    if advertiser?
      share = 100
    end
    client_members.build(user_id: created_by, share: share)
  end

  def self.import(opts)
    opts[:company_id] = User.find(opts[:user_id]).company_id
    Importers::ClientsService.new(opts).perform
  end

  def self.client_type_field(company)
    company.fields.where(name: 'Client Type').first
  end

  def self.agency_type_id(company)
    client_type_field(company).options.where(name: "Agency").first.id
  end

  def self.advertiser_type_id(company)
    client_type_field(company).options.where(name: "Advertiser").first.id
  end

  def self.custom_types(company)
    opts = {}
    client_type_field(company).options&.each{|c| opts.merge!(c.id => c.name)}
    opts
  end

  def client_type
    company.fields.where(name: 'Client Type').first.options.find_by_id(self.client_type_id)
  end

  def base_field_validations
    self.company.validations_for("#{self.client_type.try(:name)} Base Field")
  end

  def base_fields_presence
    if self.company_id.present? && self.client_type_id.present?
      factors = base_field_validations.joins(:criterion).where('values.value_boolean = ?', true).pluck(:factor)
      self.validates_presence_of(factors) if factors.length > 0
    end
  end

  def global_type_id
    if self.client_type_id
      if self.client_type_id == Client.advertiser_type_id(company)
        Client::ADVERTISER
      elsif self.client_type_id == Client.agency_type_id(company)
        Client::AGENCY
      end
    end
  end

  def last_advertiser_deal(deal)
    (last_two_advertiser_deals.first.eql?(deal) ? last_two_advertiser_deals.last : last_two_advertiser_deals.first).created_at
  end

  def last_two_advertiser_deals
    @_last_two_advertiser_deals ||= advertiser_deals.order('created_at desc').limit(2)
  end

  def last_agency_deal(deal)
    (last_two_agency_deals.first.eql?(deal) ? last_two_agency_deals.last : last_two_agency_deals.first).created_at
  end

  def last_two_agency_deals
    @_last_two_agency_deals ||= agency_deals.order('created_at desc').limit(2)
  end

  def advertiser_win_rate
    return 0 if (advertiser_deals.won.count + advertiser_deals.lost.count).zero?

    (advertiser_deals.won.count.to_f / (advertiser_deals.won.count + advertiser_deals.lost.count).to_f * 100).to_i
  end

  def agency_win_rate
    return 0 if (agency_deals.won.count + agency_deals.lost.count).zero?

    (agency_deals.won.count.to_f / (agency_deals.won.count + agency_deals.lost.count).to_f * 100).to_i
  end

  def advertiser_avg_deal_size
    advertiser_deals.won.map(&:budget).sum / advertiser_deals.won.count if advertiser_deals.won.any?
  end

  def agency_avg_deal_size
    agency_deals.won.map(&:budget).sum / agency_deals.won.count if agency_deals.won.any?
  end

  def upsert_custom_fields(params)
    if self.account_cf.present?
      self.account_cf.update(params)
    else
      cf = self.build_account_cf(params)
      cf.save
    end
  end

  def advertiser_deals_open_pipeline
    advertiser_deals
      .open
      .pluck(:budget)
      .compact
      .reduce(:+)
      &.round(0)
      &.to_i
  end

  def self.workflowable_reflections
    %i{ account_cf }
  end

  private

  def self.import_custom_field(obj, row)
    params = {}

    @custom_field_names.each do |cf|
      params[cf.field_name] = row[cf.to_csv_header]
    end

    if params.compact.any?
      obj.upsert_custom_fields(params)
    end
  end

  def setup_egnyte_folders
    Egnyte::SetupClientFoldersWorker.perform_async(company.egnyte_integration.id, id) if company.egnyte_integration
  end

  def update_egnyte_folder
    return unless company.egnyte_integration && (previous_changes[:name] || previous_changes[:parent_client_id])

    parent_changed = previous_changes[:parent_client_id].present?

    Egnyte::UpdateClientFolderWorker.perform_async(company.egnyte_integration.id, id, parent_changed)
  end
end
