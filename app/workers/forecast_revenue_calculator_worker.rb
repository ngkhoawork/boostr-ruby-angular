class ForecastRevenueCalculatorWorker < BaseWorker
  def perform(io_change)
    manage_revenue_facts(
      io_change['time_period_ids'],
      io_change['user_ids'],
      io_change['product_ids']
    )
  end

  private

  def manage_revenue_facts(time_period_ids, user_ids, product_ids)
    time_periods = TimePeriod.where(id: time_period_ids)
    users = User.where(id: user_ids)
    products = Product.where(id: product_ids)
    time_periods.each do |time_period|
      users.each do |user|
        products.each do |product|
          forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
          forecast_revenue_fact_calculator.calculate()
        end
      end
    end
  end
end