class Csv::ContactsService < Csv::BaseService
  def initialize(company, records)
    @cf_headers = company.contact_cf_names.where.not(disabled: true).order(position: :asc).pluck(:field_label)
    @records = records.includes(:primary_client, :address, :non_primary_clients, :values)
  end

  private

  attr_reader :cf_headers

  def decorated_records
    records.map { |record| Csv::ContactDecorator.new(record) }
  end

  def headers
    default_headers + cf_headers
  end

  def default_headers
    [
      'Id',
      'Name',
      'Works At',
      'Position',
      'Email',
      'Street1',
      'Street2',
      'City',
      'State',
      'Zip',
      'Country',
      'Phone',
      'Mobile',
      'Created Date',
      'Related Accounts',
      'Job Level'
    ]
  end
end
