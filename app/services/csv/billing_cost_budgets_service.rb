class Csv::BillingCostBudgetsService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::BillingCostBudgetsDecorator.new(record, field, company) }
  end

  def headers
    headers = [
      'IO Number',
      'Name',
      'Advertiser',
      'Agency',
      'Seller',
      'Account Manager',
      'Product'
    ]
    if company.product_options_enabled
      headers << company.product_option1 if company.product_option1_enabled
      headers << company.product_option2 if company.product_option2_enabled
    end
    headers += [
      'Amount',
      'Cost Type',
      'Actualization Status'
    ]
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
