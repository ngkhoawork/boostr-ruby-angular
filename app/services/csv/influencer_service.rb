class Csv::InfluencerService < Csv::BaseService
  private

  def decorated_records
    records.map { |record| Csv::InfluencerDecorator.new(record) }
  end

  def headers
    [
      'Id',
      'Name',
      'Network',
      'Agreement Type',
      'Agreement Fee',
      'Email',
      'Phone',
      'Street',
      'City',
      'State',
      'Country',
      'Postal Code',
      'Active'
    ]
  end
end
