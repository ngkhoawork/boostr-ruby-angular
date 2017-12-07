class Csv::BaseService
  def initialize(records)
    @records = records
  end

  def perform
    generate_csv
  end

  private

  attr_reader :records

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers.map { |attr| record.public_send(attr.parameterize('_')) }
      end
    end
  end
end
