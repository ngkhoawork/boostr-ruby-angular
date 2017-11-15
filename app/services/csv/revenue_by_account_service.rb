class Csv::RevenueByAccountService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
    Name: :name,
    Category: :category_id,
    Region: :client_region_id,
    Segment: :client_segment_id,
    Team: :team_name,
    Seller: :seller_names,
    Total: :total_revenue
  }.freeze

  private

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers.map do |header|
          grouping_attribute(record, header) || specific_month_revenue_attribute(record, header)
        end
      end
    end
  end

  def decorated_records
    records.map { |record| Csv::RevenueByAccountDecorator.new(record) }
  end

  def headers
    @headers ||= HEADER_ATTRIBUTES_MAPPING.keys[0..-2] + month_headers + HEADER_ATTRIBUTES_MAPPING.keys[-1..-1]
  end

  def month_headers
    records[0].revenues.keys
  end

  def specific_month_revenue_attribute(record, header)
    record.revenues[header]
  end

  def grouping_attribute(record, header)
    attr_name = HEADER_ATTRIBUTES_MAPPING[header.to_sym]

    return unless attr_name

    attr = record.send(attr_name)

    (attr_name =~ /_id/ && attr) ? Option.find(attr).name : attr
  end

  def month_position(header)
    Date::MONTHNAMES.index(header)
  end
end
