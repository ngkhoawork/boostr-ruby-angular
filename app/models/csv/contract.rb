class Csv::Contract
  include ActiveModel::Validations

  attr_accessor :name, 
                :created_date, 
                :restricted, 
                :type, 
                :status, 
                :auto_renew, 
                :start_date, 
                :end_date, 
                :auto_notifications, 
                :curr_cd,
                :amount,
                :description,
                :days_notice_required,
                :deal_name,
                :deal_id,
                :publisher_name,
                :advertiser_name,
                :agency_name,
                :agency_holding_name,
                :company_id

  validates_presence_of :name, :type, :company_id
  validates_numericality_of :amount, :days_notice_required, allow_blank: true
  validate :validate_advertiser_existence
  validate :validate_agency_existence
  validate :validate_deal_existence
  validate :validate_publisher_existence
  validate :validate_agency_holding_existence
  validate :validate_type_existence
  validate :validate_status_existence
  validate :validate_currency_existence
  validate :validate_created_date_format
  validate :validate_start_date_format
  validate :validate_end_date_format

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    contract.tap do |c|
      c.created_at = formatted_date(created_date) if created_date.present?
      c.restricted = true?(restricted)
      c.type = contract_type
      c.status = contract_status
      c.auto_renew = true?(auto_renew)
      c.start_date = formatted_date(start_date)
      c.end_date = formatted_date(end_date)
      c.auto_notifications = true?(auto_notifications)
      c.currency = currency
      c.amount = amount.to_d
      c.description = description
      c.days_notice_required = days_notice_required.to_i
      c.deal = deal
      c.publisher = publisher
      c.advertiser = advertiser
      c.agency = agency
      c.holding_company = holding_company
      c.save!
    end
  end

  private

  def true?(obj)
    obj.to_s == 'true' || obj.to_s == '1'
  end

  def company
    @_company ||= Company.find(company_id)
  end

  def contract
    @_contract ||= company.contracts.find_or_initialize_by(name: name)
  end

  def client_types
    @_client_types ||= company.fields.find_by(subject_type: 'Client', name: 'Client Type', value_type: 'Option')
                              &.options
  end

  def contract_type
    @_contract_type ||= company.fields.find_by(subject_type: 'Contract', name: 'Type', value_type: 'Option')
                                &.options&.find_by(name: type)
  end

  def contract_status
    @_contract_status ||= company.fields.find_by(subject_type: 'Contract', name: 'Status', value_type: 'Option')
                                &.options&.find_by(name: status)
  end

  def advertiser_type_id
    @_advertiser_type_id ||= client_types&.find_by(name: 'Advertiser')&.id
  end

  def agency_type_id
    @_agency_type_id ||= client_types&.find_by(name: 'Agency')&.id
  end

  def advertiser
    @_advertiser ||= company.clients.find_by(name: advertiser_name, client_type_id: advertiser_type_id)
  end

  def agency
    @_agency ||= company.clients.find_by(name: agency_name, client_type_id: agency_type_id)
  end

  def deal
    @_deal ||= company.deals.find_by(name: deal_name, id: deal_id)
  end

  def publisher
    @_publisher ||= company.publishers.find_by(name: publisher_name)
  end

  def holding_company
    @_holding_company ||= HoldingCompany.find_by(name: agency_holding_name)
  end

  def currency
    @_currency ||= Currency.find_by(curr_cd: curr_cd)
  end

  def validate_advertiser_existence
    if advertiser_name.present? && advertiser.nil?
      errors.add(:base, "Advertiser with --#{advertiser_name}-- name doesn't exist")
    end
  end

  def validate_agency_existence
    if agency_name.present? && agency.nil?
      errors.add(:base, "Agency with --#{agency_name}-- name doesn't exist")
    end
  end

  def validate_deal_existence
    if (deal_id.present? || deal_name.present?) && deal.nil?
      errors.add(:base, "Deal with --#{deal_id}-- ID and --#{deal_name}-- name doesn't exist")
    end
  end

  def validate_publisher_existence
    if publisher_name.present? && publisher.nil?
      errors.add(:base, "Publisher with --#{publisher_name}-- name doesn't exist")
    end
  end

  def validate_agency_holding_existence
    if agency_holding_name.present? && holding_company.nil?
      errors.add(:base, "Agency holding with --#{agency_holding_name}-- name doesn't exist")
    end
  end

  def validate_type_existence
    if type.present? && contract_type.nil?
      errors.add(:base, "Contract type with --#{type}-- name doesn't exist")
    end
  end

  def validate_status_existence
    if status.present? && contract_status.nil?
      errors.add(:base, "Contract status with --#{status}-- name doesn't exist")
    end
  end

  def validate_currency_existence
    if curr_cd.present? && currency.nil?
      errors.add(:base, "Currency --#{curr_cd}-- doesn't exist")
    end
  end

  def validate_created_date_format
    formatted_date(created_date)
  rescue
    errors.add(:base, "Created date --#{created_date}-- does not match mm/dd/yyyy format")
  end

  def validate_start_date_format
    formatted_date(start_date)
  rescue
    errors.add(:base, "Start date --#{start_date}-- does not match mm/dd/yyyy format")
  end

  def validate_end_date_format
    formatted_date(end_date)
  rescue
    errors.add(:base, "End date --#{end_date}-- does not match mm/dd/yyyy format")
  end

  def formatted_date(date)
    Date.strptime(date.gsub(/[-:]/, '/'), '%m/%d/%Y') if date.present?
  rescue
    raise 'Date format does not match mm/dd/yyyy pattern'
  end
end