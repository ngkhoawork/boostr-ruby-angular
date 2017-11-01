class Csv::RevenueByAccountService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
    Name: :name,
    Category: :category_id,
    Region: :client_region_id,
    Segment: :client_segment_id,
    Team: :team_name,
    Seller: :seller_names,
    Year: :year,
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
    @headers ||= HEADER_ATTRIBUTES_MAPPING.keys[0..-2] + specific_month_headers + HEADER_ATTRIBUTES_MAPPING.keys[-1..-1]
  end

  def specific_month_headers
    Date::MONTHNAMES[1..-1]
  end

  def specific_month_revenue_attribute(record, header)
    record.revenues[month_position(header)]
  end

  def grouping_attribute(record, header)
    record.send(HEADER_ATTRIBUTES_MAPPING[header.to_sym]) if HEADER_ATTRIBUTES_MAPPING[header.to_sym]
  end

  def month_position(header)
    Date::MONTHNAMES.index(header)
  end
end
