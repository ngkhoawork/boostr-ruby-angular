class Csv::RevenueByAccountService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
    Name: :name,
    Category: :client_category_name,
    Region: :client_region_name,
    Segment: :client_segment_name,
    Team: :team_name,
    Seller: :seller_names,
    Total: :total_revenue
  }.freeze

  private

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << record_keys.map do |header|
          grouping_attribute(record, header) || specific_month_revenue_attribute(record, header)
        end
      end
    end
  end

  def decorated_records
    records.map { |record| Csv::RevenueByAccountDecorator.new(record) }
  end

  def headers
    HEADER_ATTRIBUTES_MAPPING.keys[0..-2] + decorated_month_headers + HEADER_ATTRIBUTES_MAPPING.keys[-1..-1]
  end

  def record_keys
    HEADER_ATTRIBUTES_MAPPING.keys[0..-2] + month_headers + HEADER_ATTRIBUTES_MAPPING.keys[-1..-1]
  end

  def month_headers
    records[0].month_revenues.keys
  end

  def decorated_month_headers
    records[0].month_revenues.keys.map do |month_revenue|
      month_revenue =~ /-(\d)\z/
      $1 ? month_revenue.sub(/-(\d)\z/, "-0#{$1}") : month_revenue
    end
  end

  def specific_month_revenue_attribute(record, header)
    record.month_revenues[header]
  end

  def grouping_attribute(record, header)
    attr_name = HEADER_ATTRIBUTES_MAPPING[header.to_sym]

    record.send(attr_name) if attr_name
  end

  def month_position(header)
    Date::MONTHNAMES.index(header)
  end
end
