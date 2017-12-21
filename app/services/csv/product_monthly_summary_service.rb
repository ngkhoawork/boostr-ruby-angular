class Csv::ProductMonthlySummaryService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records['data']
    @custom_field_names = records['deal_product_cf_names']
  end

  private

  attr_reader :company, :custom_field_names

  def decorated_records
    records.map { |record| Csv::ProductMonthlySummaryDecorator.new(record, company, custom_field_names) }
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers_as_symbols.map { |attr| record.send(attr) }
      end
    end
  end

  def headers
    headers = ['Product']
    headers += custom_headers
    headers.concat [
      'Record Type',
      'Record ID',
      'Team Member',
      'Name',
      'Advertiser',
      'Agency',
      'Holding CO',
      'Stage',
      '%',
      'Budget',
      'Currency',
      'Budget USD',
      'Weighted Amt',
      'Start Date',
      'End Date',
      'Created Date',
      'Closed Date',
      'Deal Type',
      'Deal Source'
    ]
  end

  def custom_headers
    custom_field_names.map {|cf| cf['field_label']}
  end
  
  def headers_as_symbols
    @_headers_as_symbols ||= headers.map { |el| el.downcase.gsub(' ','_').to_sym }
  end
end
