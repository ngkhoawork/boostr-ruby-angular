class Csv::Activity
  extend ActiveModel::Translation

  CONTACT_DELIMITER = ';'.freeze
  CORE_COLUMNS = %i(company_id activity_id date creator advertiser agency deal type comments contacts).freeze

  attr_reader :errors

  def initialize(csv_columns = {})
    csv_columns = csv_columns.symbolize_keys.each_with_object({}) do |(key, value), acc|
      acc[key] = stripped_value_for(value)
    end

    @csv_columns = csv_columns.slice(*CORE_COLUMNS)
    @cf_csv_columns = csv_columns.except(*CORE_COLUMNS)

    raise ArgumentError, 'company_id must be present' unless @csv_columns[:company_id]

    @errors = ActiveModel::Errors.new(self)

    @db_attributes = build_db_attributes
  end

  def perform
    return false unless valid?

    activity.update!(@db_attributes)
  end

  def valid?
    @errors.blank?
  end

  def object_errors
    activity.errors.full_messages
  end

  private

  delegate :custom_field_names, to: :company

  def activity
    @activity ||= @csv_columns[:activity_id] ? Activity.find(@csv_columns[:activity_id]) : Activity.new
  end

  def build_db_attributes
    {
      company_id: @csv_columns[:company_id],
      happened_at: happened_at,
      user_id: user_id,
      created_by: user_id,
      client_id: advertiser_id,
      agency_id: agency_id,
      deal_id: deal_id,
      activity_type_id: activity_type_id,
      comment: @csv_columns[:comments],
      contact_ids: contact_ids,
      custom_field_attributes: custom_field_attributes
    }
  end

  def happened_at
    return if @csv_columns[:date].blank?

    Date.strptime(@csv_columns[:date], "%m/%d/%Y")
  rescue ArgumentError
    errors.add(:date, 'must have valid date/datetime format (MM/DD/YYYY)')
    nil
  end

  def user_id
    return if @csv_columns[:creator].blank?

    company.users.where('LOWER(email) = ?', @csv_columns[:creator].downcase).first!.id
  rescue ActiveRecord::RecordNotFound
    errors.add(:creator, 'must match users') unless errors.messages[:creator]&.include?('must match users')
    nil
  end

  def advertiser_id
    return if @csv_columns[:advertiser].blank?

    db_advertisers = company.clients.by_type_id(advertiser_type_id).by_name(@csv_columns[:advertiser])

    exact_one_db_match(db_advertisers, :advertiser)&.id
  end

  def agency_id
    return if @csv_columns[:agency].blank?

    db_agencies = company.clients.by_type_id(agency_type_id).by_name(@csv_columns[:agency])

    exact_one_db_match(db_agencies, :agency)&.id
  end

  def deal_id
    return if @csv_columns[:deal].blank?

    db_deals = company.deals.where('name ilike ?', @csv_columns[:deal])

    exact_one_db_match(db_deals, :deal)&.id
  end

  def activity_type_id
    return if @csv_columns[:type].blank?

    company.activity_types.where('name ilike ?', @csv_columns[:type]).first!.id
  rescue ActiveRecord::RecordNotFound
    errors.add(:type, 'must match activity types')
    nil
  end

  def contact_ids
    @csv_columns[:contacts]&.split(CONTACT_DELIMITER)&.inject([]) do |acc, contact_email|
      begin
        acc << Contact.by_email(contact_email, company.id).first!.id
      rescue ActiveRecord::RecordNotFound
        errors.add(:contact, "must match contacts")
        acc
      end
    end
  end

  def custom_field_attributes
    custom_field_names.each_with_object({}) do |cf_name, acc|
      acc[cf_name.field_name] = @cf_csv_columns[cf_name.to_csv_header]
    end
  end

  def advertiser_type_id
    @advertiser_type_id ||= Client.advertiser_type_id(company)
  end

  def agency_type_id
    @agency_type_id ||= Client.agency_type_id(company)
  end

  def company
    @company ||= Company.find(@csv_columns[:company_id])
  end

  def exact_one_db_match(relation, col_name)
    if relation.one?
      relation[0]
    elsif relation.none?
      errors.add(col_name, "must match #{relation.table_name}")
      nil
    else
      errors.add(col_name, "must match #{relation.table_name} only once")
      nil
    end
  end

  def stripped_value_for(value)
    value.is_a?(String) ? value.strip : value
  end
end
