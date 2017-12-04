class Models::AccountCompanyDataService
  def initialize(company_id)
    @company_id = company_id
  end

  def perform
    data = OpenStruct.new
    data.account_cf_names = account_cf_names
    data.category_field = category_field
    data.segment_field = segment_field
    data.region_field = region_field
    data.type_field = type_field
    data.advertiser_type_id = type_field.options.where(name: "Advertiser").first.id
    data.agency_type_id = type_field.options.where(name: "Agency").first.id

    data
  end

  private

  def type_field
    Field.find_by( company_id: @company_id, subject_type: 'Client', name: 'Client Type')
  end

  def account_cf_names
    AccountCfName.where(company_id: @company_id)
  end

  def segment_field
    Field.find_by( company_id: @company_id, subject_type: 'Client', name: 'Segment')
  end

  def region_field
    Field.find_by( company_id: @company_id, subject_type: 'Client', name: 'Region')
  end

  def category_field
    Field.find_by(company_id: @company_id, subject_type: 'Client', name: 'Category')
  end
end
