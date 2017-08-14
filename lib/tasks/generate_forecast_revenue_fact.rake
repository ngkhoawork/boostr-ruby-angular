require 'forecast_revenue_fact_calculator'
namespace :generate_forecast_revenue_facts do
  include ForecastRevenueFactCalculator
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    companies = []
    if args[:company_id] == 'all'
      companies = Company.all
    else
      companies = Company.where(id: args[:company_id])
    end
    companies.each do |company|
      company.time_periods.each do |time_period|
        company.users.each do |user|
          company.products.each do |product|
            forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
            forecast_revenue_fact_calculator.calculate()
          end
        end
      end
    end
  end

end
