class Csv::IoCostService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::IoCostDecorator.new(record, company) }
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
      'IO Account Manager2'
    ]
  end
end
