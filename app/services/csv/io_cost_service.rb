class Csv::IoCostService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::IoCostDecorator.new(record, company, field) }
  end

  def headers
    [
      'IO Number',
      'Cost ID',
      'Product ID',
      'Product Name',
      'Type',
      'Month',
      'Amount',
      'IO Name',
      'IO Seller',
      'IO Account Manager',
      'Second IO Account Manager'
    ]
  end

  def field
    @_field ||= company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
  end
end
