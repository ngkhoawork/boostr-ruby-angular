class Csv::BillingCostsService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::BillingCostsDecorator.new(record, company, field) }
  end

  def headers
    [
      'IO Number',
      'Name',
      'Product',
      'Amount',
      'Cost Type'
    ]
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
