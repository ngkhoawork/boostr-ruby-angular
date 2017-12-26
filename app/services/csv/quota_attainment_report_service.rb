class Csv::QuotaAttainmentReportService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::QuotaAttainmentDecorator.new(record, company) }
  end

  def sorted_records
    decorated_records.sort_by{|e| [e.team, e.is_leader? ? 0 : 1]}
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headers
      sorted_records.each do |record|
        csv << headers_as_symbols.map { |attr| record.send(attr) }
      end
    end
  end

  def headers
    [
      'Name',
      'Team',
      'Quota',
      'Revenue',
      'Pipeline (W)',
      'Forecast Amt',
      'Gap to Quota',
      '% to Quota',
      '% Booked'
    ]
  end

  def headers_as_symbols
    @_headers_as_symbols ||= headers.map do |el| 
      el.downcase
        .gsub(' ','_')
        .gsub('%','percent')
        .tr('()','')
        .to_sym 
    end
  end
end
