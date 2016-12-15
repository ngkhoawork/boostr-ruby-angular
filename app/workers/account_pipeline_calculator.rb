class AccountPipelineCalculator
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: false

  def perform()
    Company.all.each do |company|
      time_dimensions = TimeDimension.all
      total_budgets = {}
      time_dimensions.each do |time_dimension|
        total_budgets[time_dimension.id] = 0
      end
      clients = Client.where(company_id: company.id)
      clients.each do |client|
        deal_product_budgets = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id = deal_products.id")
        .joins("INNER JOIN deals ON deal_products.deal_id = deals.id")
        .joins("INNER JOIN deal_members ON deals.id = deal_members.deal_id")
        .joins('INNER JOIN users ON deal_members.user_id = users.id')
        .joins("INNER JOIN client_members ON users.id = client_members.user_id")
        .where("client_members.client_id = ? AND deals.company_id = ? AND deals.open IS TRUE", client.id, company.id).select("deal_product_budgets.*, deal_members.share, client_members.share as client_share").to_a
        # puts deal_product_budgets
        deal_product_budgets.each do |deal_product_budget|
          daily_budget = (deal_product_budget.budget / 100.0) / (deal_product_budget.end_date - deal_product_budget.start_date + 1).to_f
          share = deal_product_budget.share
          client_share = deal_product_budget.client_share

          time_dimensions.each do |time_dimension|
            from = [time_dimension.start_date, deal_product_budget.start_date].max
            to = [time_dimension.end_date, deal_product_budget.end_date].min
            days = [(to.to_date - from.to_date) + 1, 0].max
            total_budgets[time_dimension.id] = total_budgets[time_dimension.id] + daily_budget * days * share / 100.0 * client_share / 100.0
          end
        end
        time_dimensions.each do |time_dimension|
          account_pipeline_fact = AccountPipelineFact.find_or_initialize_by(company_id: company.id, account_dimension_id: client.id, time_dimension_id: time_dimension.id)
          account_pipeline_fact.pipeline_amount = total_budgets[time_dimension.id]
          account_pipeline_fact.save
        end
      end
    end
  end
end