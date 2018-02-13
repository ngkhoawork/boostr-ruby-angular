require 'forecast_revenue_fact_calculator'
namespace :update_content_fee_dates do
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
      if company.present?
        budgets = ContentFeeProductBudget.joins("LEFT JOIN content_fees ON content_fee_product_budgets.content_fee_id = content_fees.id").joins("LEFT JOIN ios ON ios.id = content_fees.io_id").where("ios.company_id = ? AND content_fee_product_budgets.end_date > ios.end_date", company.id)
        budgets.each do |budget|
          end_date = budget&.content_fee&.io&.end_date
          budget.update(end_date: end_date) if end_date
        end

        budgets.each do |budget|
          content_fee = budget.content_fee
          io = content_fee&.io
          puts "======="
          puts budget.id
          product = content_fee&.product
          if io.present? && product.present?
            time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
            time_periods.each do |time_period|
              io.users.each do |user|
                forecast_revenue_fact_calculator = ForecastRevenueFactCalculator::Calculator.new(time_period, user, product)
                forecast_revenue_fact_calculator.calculate()
              end
            end
          end
        end
      end
    end
  end

end
