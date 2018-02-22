class TimePeriod < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :quotas
  has_many :snapshots

  validates :name, :start_date, :end_date, presence: true
  validate :unique_name

  after_create do
    company.users.each do |user|
      quotas.create(user_id: user.id, company_id: company.id)
    end
    create_forecast_dimension
    update_forecast_fact_callback
  end

  after_destroy do |time_period_record|
    delete_dimension(time_period_record)
  end

  after_update do
    if start_date_changed? || end_date_changed? || period_type_changed?
      update_forecast_fact_callback
    end
  end

  def create_forecast_dimension
    period_types = ['year', 'quarter', 'month']
    if period_types.include?(self.period_type)
      ForecastTimeDimension.create(
        id: self.id,
        name: self.name,
        start_date: self.start_date,
        end_date: self.end_date,
        days_length: (self.end_date - self.start_date + 1).to_i
      )
    end
  end

  def delete_dimension(time_period_record)
    forecast_time_dimension = ForecastTimeDimension.find_by(id: time_period_record.id)
    if forecast_time_dimension.present?
      ForecastTimeDimension.destroy(time_period_record.id)
      ForecastPipelineFact.destroy_all(forecast_time_dimension_id: time_period_record.id)
      ForecastRevenueFact.destroy_all(forecast_time_dimension_id: time_period_record.id)
    end
  end

  scope :current_year_quarters, -> (company_id) do
    where(company_id: company_id).where("date(end_date) - date(start_date) < 100")
                                 .where("extract(year from start_date) = ?", Date.current.year)
  end

  scope :current_quarter, -> do
    where(period_type: 'quarter').find_by('start_date <= ? AND end_date >= ?', Date.current, Date.current)
  end

  scope :all_quarter, -> { where(period_type: 'quarter') }
  scope :years_only, -> { where(period_type: 'year') }
  scope :closest, -> { where('end_date >= ?', Date.current).order(:start_date) }

  def self.now
    where('start_date <= ? AND end_date >= ?', Time.now, Time.now).first
  end

  def update_forecast_fact_callback
    time_period_ids = [self.id]
    user_ids = company.users.collect{|user| user.id}
    product_ids = company.products.collect{|product| product.id}
    stage_ids = company.stages.collect{|stage| stage.id}
    io_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids}
    deal_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids, stage_ids: stage_ids}
    ForecastRevenueCalculatorWorker.perform_async(io_change)
    ForecastPipelineCalculatorWorker.perform_async(deal_change)
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company && name
    scope = company.time_periods.where('LOWER(name) = ?', self.name.downcase)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end
end
