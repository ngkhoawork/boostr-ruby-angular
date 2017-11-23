class Csv::PublisherAllFieldsReportService < Csv::BaseService
  private

  def decorated_records
    @decorated_records ||= records.map { |record| Csv::PublisherAllFieldsReportDecorator.new(record) }
  end

  def headers
    @headers ||=
      %w(
        id
        name
        comscore
        website
        estimated_monthly_impressions
        actual_monthly_impressions
        type publisher_stage
        client created_at
      )
  end
end
