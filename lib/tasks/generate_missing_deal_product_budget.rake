namespace :generate_missing_deal_product_budget do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    return unless args[:company_id]

    company = Company.find(args[:company_id])
    return unless company
    
    deal_products = company.deal_products.includes({
      deal: {},
      deal_product_budgets: {}
    })
    deal_products.each do |deal_product|
      create_budgets_for_product(deal_product)
    end
  end

  def create_budgets_for_product(deal_product)
    months = deal_product.deal.months
    budgets = deal_product.deal_product_budgets

    return if budgets.count >= months.count

    months.each.with_index do |month, index|
      period = Date.new(*month)
      deal_product_budgets = budgets.for_year_month(period)
      
      next if deal_product_budgets.any?
      puts deal_product.id
      deal = deal_product.deal
      budgets.create(
        start_date: [period, deal.start_date].max,
        end_date: [period.end_of_month, deal.end_date].min,
        budget: 0,
        budget_loc: 0
      )
    end

  end

end
