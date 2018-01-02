class Csv::ActivityDetailService < Csv::BaseService
  private

  def decorated_records
    records.map { |record| Csv::ActivityDetailDecorator.new(record) }
  end

  def headers
    %w(Date Type Comments Advertiser Agency Contacts Deal Publisher Creator Team)
  end
end
