class Csv::PublisherAllFieldsReportService < Csv::BaseService
  private

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << generate_base_columns(record) + generate_custom_field_columns(record)
      end
    end
  end

  def decorated_records
    @decorated_records ||= records.map { |record| Csv::PublisherAllFieldsReportDecorator.new(record) }
  end

  def headers
    @headers ||= base_headers + custom_field_headers
  end

  def generate_base_columns(record)
    base_headers.map { |attr| record.send(attr.parameterize.underscore) }
  end

  def generate_custom_field_columns(record)
    custom_field_headers.map { |attr| record.custom_fields[attr] if record.custom_fields }
  end

  def base_headers
    [
      'Id',
      'Name',
      'Comscore',
      'Website',
      'Estimated Monthly Impressions',
      'Monthly Impressions (90-Day Avg)',
      'Fill Rate (90-Day Avg)',
      'Type',
      'Publisher Stage',
      'Client',
      'Created At',
      'Revenue Lifetime',
      'Revenue Ytd',
      'Export Date'
    ]
  end

  def custom_field_headers
    @custom_field_headers ||= company ? company.publisher_custom_field_names.map(&:field_label) : []
  end

  def company
    records[0]&.company
  end
end
