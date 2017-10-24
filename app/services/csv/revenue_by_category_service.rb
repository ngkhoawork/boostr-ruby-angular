class Csv::RevenueByCategoryService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
    Category: :category_id,
    Year: :year,
    Total: :total_revenue
  }.freeze

  private

  def decorated_records
    records.map { |record| Csv::RevenueByCategoryDecorator.new(record) }
  end

  def headers
    %w(Category Year) + Date::MONTHNAMES[1..-1] + %w(Total)
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers.map do |header|
          default_attribute(record, header) || specific_attribute(record, header)
        end
      end
    end
  end

  def default_attribute(record, header)
    record.revenues[Date::MONTHNAMES.index(header)]
  end

  def specific_attribute(record, header)
    record.send(HEADER_ATTRIBUTES_MAPPING[header.to_sym]) if HEADER_ATTRIBUTES_MAPPING[header.to_sym]
  end
end
