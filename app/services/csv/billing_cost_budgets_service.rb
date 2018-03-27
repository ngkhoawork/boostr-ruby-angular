class Csv::BillingCostBudgetsService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::BillingCostBudgetsDecorator.new(record, company, field) }
  end

  def headers
    [
      'IO Number',
      'Name',
      'Advertiser',
      'Agency',
      'Product',
      'Amount',
      'Cost Type'
    ]
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
