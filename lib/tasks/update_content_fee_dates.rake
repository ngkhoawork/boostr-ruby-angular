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
        update_start_date(company)
        update_end_date(company)
      end
    end
  end

  def update_end_date(company)
    budgets = ContentFeeProductBudget
      .joins("LEFT JOIN content_fees ON content_fee_product_budgets.content_fee_id = content_fees.id")
      .joins("LEFT JOIN ios ON ios.id = content_fees.io_id")
      .where("ios.company_id = ? AND content_fee_product_budgets.end_date > ios.end_date", company.id)
    budgets.each do |budget|
      end_date = budget&.content_fee&.io&.end_date
      budget.update(end_date: end_date) if end_date
      update_forecast(company, budget)
    end
  end

  def update_start_date(company)
    budgets = ContentFeeProductBudget
      .joins("LEFT JOIN content_fees ON content_fee_product_budgets.content_fee_id = content_fees.id")
      .joins("LEFT JOIN ios ON ios.id = content_fees.io_id")
      .where("ios.company_id = ? AND content_fee_product_budgets.start_date < ios.start_date", company.id)
    budgets.each do |budget|
      start_date = budget&.content_fee&.io&.start_date
      budget.update(start_date: start_date) if start_date
      update_forecast(company, budget)
      
    end
  end

  def update_forecast(company, budget)
    puts "======="
    puts budget.id
    content_fee = budget.content_fee
    io = content_fee&.io
    product = content_fee&.product
    if io.present? && product.present?
      time_periods = company.time_periods
        .where("end_date >= ? and start_date <= ?", io.start_date, io.end_date)
      time_periods.each do |time_period|
        io.users.each do |user|
          ForecastRevenueFactCalculator::Calculator
            .new(time_period, user, product)
            .calculate
        end
      end
    end
  end
end
