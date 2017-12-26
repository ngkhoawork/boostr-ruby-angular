class ForecastPmpRevenueCalculatorWorker < BaseWorker
  def perform(pmp_change)
    manage_revenue_facts(
      pmp_change['time_period_ids'],
      pmp_change['user_ids'],
      pmp_change['product_ids']
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
          Forecast::PmpRevenueCalcService.new(time_period, user, product).perform()
        end
      end
    end
  end
end