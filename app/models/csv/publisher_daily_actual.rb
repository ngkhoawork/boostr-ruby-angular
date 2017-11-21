class Csv::PublisherDailyActual
  include ActiveModel::Validations

  attr_accessor :date, :available_impressions, :filled_impressions, :company_id, :publisher_id, :publisher_name

  validates :date, :available_impressions, :filled_impressions, :company_id, presence: true
  validates :publisher_id, presence: true, if: ->(obj) { obj.publisher_name.nil? }
  validates :publisher_name, presence: true, if: ->(obj) { obj.publisher_id.nil? }
  validates :publisher, presence: { message: 'not found by given id, name' }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    record.update_attributes!(publisher_daily_actual_params)
  end

  private

  def record
    ::PublisherDailyActual.find_or_initialize_by(date: formatted_date, publisher: publisher)
  end

  def publisher
    @publisher ||= Publisher.where(
      '(id = :id OR name = :name) AND company_id = :company_id',
      id: publisher_id,
      name: publisher_name,
      company_id: company_id
    ).first
  end

  def publisher_daily_actual_params
    {
      date: formatted_date,
      available_impressions: available_impressions,
      filled_impressions: filled_impressions,
      publisher: publisher
    }
  end

  def formatted_date
    @formatted_date ||= Date.parse(date)
  end
end
