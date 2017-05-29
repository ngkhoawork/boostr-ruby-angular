class Csv::BaseService
  def initialize(records, options = {})
    @records = records
    @options = options
  end

  def perform
    generate_csv
  end

  private

  attr_reader :records, :options

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers.map { |attr| record.send(attr.downcase) }
      end
    end
  end
end
