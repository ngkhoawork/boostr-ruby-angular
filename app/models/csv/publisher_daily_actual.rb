class Csv::PublisherDailyActual
  include ActiveModel::Validations

  attr_accessor :date,
                :available_impressions,
                :filled_impressions,
                :company_id,
                :publisher_id,
                :publisher_name,
                :total_revenue,
                :ecpm,
                :curr_symbol

  validates :date, :available_impressions, :filled_impressions, :total_revenue, :ecpm, :currency, :company_id,
            presence: true
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
    @publisher ||= sync_publisher_name(fetch_publisher_by_id_or_name)
  end

  def currency
    @currency ||= Currency.where('curr_symbol = :currency OR curr_cd = :currency', currency: curr_symbol).first
  end

  def publisher_daily_actual_params
    {
      date: formatted_date,
      available_impressions: available_impressions,
      filled_impressions: filled_impressions,
      total_revenue: total_revenue,
      ecpm: ecpm,
      currency: currency,
      publisher: publisher
    }
  end

  def fetch_publisher_by_id_or_name
    if publisher_id
      Publisher.find_by(id: publisher_id, company_id: company_id)
    elsif publisher_name
      Publisher.where(
        'LOWER(name) = :downcased_name AND company_id = :company_id',
        downcased_name: publisher_name.downcase,
        company_id: company_id
      ).first
    end
  end

  def sync_publisher_name(publisher)
    return unless publisher && publisher_name

    publisher.update(name: publisher_name) unless publisher.name.downcase == publisher_name.downcase

    publisher
  end

  def formatted_date
    @formatted_date ||= Date.strptime(date.gsub(/[-:]/, '/'), '%m/%d/%Y')
  rescue
    raise 'Date format does not fit MM/DD/YYYY pattern'
  end
end
