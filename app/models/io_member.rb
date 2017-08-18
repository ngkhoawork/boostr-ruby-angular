class IoMember < ActiveRecord::Base
  belongs_to :io
  belongs_to :user

  validates :user_id, :io_id, :share, presence: true

  after_update do
    update_revenue_fact_user(self) if share_changed?
  end

  after_destroy do |io_member|
    update_revenue_fact_user(self) if self.share > 0
  end

  def update_revenue_fact_user(io_member)
    user = io_member.user
    io = io_member.io
    company = io.company
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
    time_periods.each do |time_period|
      io.products.each do |product|
        forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
        forecast_revenue_fact_calculator.calculate()
      end
    end
  end

  def name
    user.name if user.present?
  end

  def as_json(options = {})
    super(
      options.merge(
        include: [
          :user
        ]
      )
    )
  end
end
