class RevenueDataWarehouse
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: false

  def perform
    generate_account_revenue_facts
  end

  def generate_account_revenue_facts
    AccountRevenueFact.delete_all
    ios = Io.all.includes(:content_fees, :content_fee_product_budgets, :display_line_items, :display_line_item_budgets)

    ios.each do |io|
      time_dimensions = TimeDimension.where('start_date <= ? and end_date >= ?', io.end_date, io.start_date)
      time_dimensions.each do |time_dimension|
        time_period_revenue = io.total_effective_revenue_budget(time_dimension.start_date, time_dimension.end_date)
        [io.advertiser, io.agency].compact.each do |client|
          revenue_fact = AccountRevenueFact.find_or_initialize_by(
            company_id: client.company_id,
            account_dimension_id: client.id,
            time_dimension_id: time_dimension.id
          )
          revenue_amount = [revenue_fact.revenue_amount, time_period_revenue].compact.reduce(:+)

          revenue_fact.update(
            category_id: client.client_category_id,
            subcategory_id: client.client_subcategory_id,
            revenue_amount: revenue_amount
          )
        end
      end
    end
  end
end
