class Csv::AccountsService < Csv::BaseService
  def self.default_headers
    %w(
      Id
      Name
      Type
      Parent
      Category
      Subcategory
      Address
      City
      State
      Zip
      Phone
      Website
      Team\ members
      Region
      Segment
      Holding\ Company
    )
  end

  def initialize(records, company)
    @records = preload_assocs(records).order(:id)
    @company = company
  end

  delegate :default_headers, to: :class

  private

  def decorated_records
    records.map do |record|
      Csv::AccountDecorator.new(
        record,
        custom_types: custom_types,
        cf_names: cf_names
      )
    end
  end

  def headers
    default_headers + cf_headers
  end

  def cf_headers
    cf_names.map(&:field_label)
  end

  def preload_assocs(accounts)
    accounts.includes(
      :parent_client,
      :address,
      :client_category,
      :client_subcategory,
      :client_region,
      :client_segment,
      :holding_company,
      :account_cf,
      client_members: [:user]
    )
  end

  def cf_names
    @cf_names ||= @company.account_cf_names.where('disabled = FALSE OR disabled IS NULL').order(position: :asc)
  end

  def company_agency_type_id
    @company_agency_type_id ||= Client.agency_type_id(@company)
  end

  def company_advertiser_type_id
    @company_advertiser_type_id ||= Client.advertiser_type_id(@company)
  end

  def custom_types
    @custom_type ||= Client.custom_types(@company)
  end
end
