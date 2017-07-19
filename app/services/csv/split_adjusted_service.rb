class Csv::SplitAdjustedService < Csv::BaseService
  private

  def decorated_records
    records.map { |record| Csv::SplitAdjustedDecorator.new(record) }
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
    [
      'Deal Id',
      'Name',
      'Advertiser',
      'Agency',
      'Team Member',
      'Split',
      'Stage',
      '%',
      'Budget',
      'Currency',
      'Budget USD',
      'Split Budget USD',
      'Type',
      'Source',
      'Next steps',
      'Start date',
      'End date',
      'Created Date',
      'Closed Date'
    ]
  end

  def headers_as_symbols
    @_headers_as_symbols ||= headers.map { |el| el.downcase.gsub(' ','_').to_sym }
  end
end
