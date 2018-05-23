class Csv::ActivityDetailService < Csv::BaseService
  def self.default_headers
    %w(
      Date
      Type
      Comments
      Advertiser
      Agency
      Contacts
      Deal
      Publisher
      Creator
      Team
    )
  end

  def initialize(records, company)
    @records = records.includes(:custom_field).order(:id)
    @company = company
  end

  private

  delegate :default_headers, to: :class

  def decorated_records
    records.map { |record| Csv::ActivityDetailDecorator.new(record, custom_field_names: custom_field_names) }
  end

  def headers
    default_headers + custom_field_headers
  end

  def custom_field_headers
    custom_field_names.map(&:field_label)
  end

  def custom_field_names
    @custom_field_names ||=
      @company
        .custom_field_names
        .for_model('Activity')
        .where('disabled = FALSE OR disabled IS NULL')
        .order(position: :asc)
  end
end
