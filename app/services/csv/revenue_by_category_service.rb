class Csv::RevenueByCategoryService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
    Category: :category_id,
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
    records.map { |record| Csv::RevenueByCategoryDecorator.new(record) }
  end

  def headers
    @headers ||= HEADER_ATTRIBUTES_MAPPING.keys[0..-2] + month_headers + HEADER_ATTRIBUTES_MAPPING.keys[-1..-1]
  end

  def month_headers
    Date::MONTHNAMES[1..-1]
  end

  def specific_month_revenue_attribute(record, header)
    record.revenues[month_position(header)]
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
