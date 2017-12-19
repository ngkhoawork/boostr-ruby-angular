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
    decorated_records.sort_by{|e| [e.team_name, e.is_leader? ? 0 : 1]}
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headers
      sorted_records.each do |record|
        csv << [
          record.name,
          record.team_name,
          record.quota,
          record.revenue,
          record.weighted_pipeline,
          record.amount,
          record.gap_to_quota,
          record.percent_to_quota,
          record.percent_booked
        ]
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
end
