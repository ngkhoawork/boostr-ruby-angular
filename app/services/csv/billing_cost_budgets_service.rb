class Csv::BillingCostBudgetsService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::BillingCostBudgetsDecorator.new(record, field) }
  end

  def headers
    [
      'IO Number',
      'Name',
      'Advertiser',
      'Agency',
      'Seller',
      'Account Manager',
      'Product',
      'Amount',
      'Cost Type',
      'Actualization Status'
    ]
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
