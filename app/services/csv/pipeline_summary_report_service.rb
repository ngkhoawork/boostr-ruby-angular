class Csv::PipelineSummaryReportService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::PipelineSummaryReportDecorator.new(record, company) }
  end

  def generate_csv
    CSV.generate do |csv|
      csv << all_headers

      decorated_records.each do |record|
        csv << headers_as_symbols.map { |attr| record.send(attr) }
      end
    end
  end

  def headers
    [
      'Deal Id',
      'Name',
      'Advertiser',
      'Category',
      'Agency',
      'Holding Company',
      'Budget USD',
      'Budget',
      'Stage',
      '%',
      'Start Date',
      'End Date',
      'Created Date',
      'Closed Date',
      'Close Reason',
      'Close Comments',
      'Members',
      'Team',
      'Type',
      'Source',
      'Initiative',
      'Billing Contact'
    ]
  end

  def deal_custom_fields
    company.deal_custom_field_names.pluck(:field_label)
  end

  def all_headers
    headers.push(deal_custom_fields).flatten
  end

  def headers_as_symbols
    @_headers_as_symbols ||= all_headers.map { |el| el.downcase.gsub(' ','_').to_sym }
  end
end
