class Csv::RevenueByCategoryService < Csv::BaseService
  HEADER_ATTRIBUTES_MAPPING = {
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
          category_attr(record, header) || month_revenue_attr(record, header) || header_linked_attr(record, header)
        end
      end
    end
  end

  def month_revenue_attr(record, header)
    record.revenues[Date::MONTHNAMES.index(header)]
  end

  def header_linked_attr(record, header)
    record.send(HEADER_ATTRIBUTES_MAPPING[header.to_sym]) if HEADER_ATTRIBUTES_MAPPING[header.to_sym]
  end

  def category_attr(record, header)
    return unless header.to_sym == :Category

    # Store categories in hash table to avoid redundant DB queries
    @categories ||= {}
    @categories[record.category_id] ||= Option.find(record.category_id).name
  end
end
