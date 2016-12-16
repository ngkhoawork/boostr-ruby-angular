class AccountPipelineCalculator
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: false

  def perform()
    Company.all.each do |company|
      time_dimensions = TimeDimension.all

      clients = Client.where(company_id: company.id)
      clients.each do |client|
        total_budgets = {}
        time_dimensions.each do |time_dimension|
          total_budgets[time_dimension.id] = 0
        end
        deal_product_budgets = DealProductBudget.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id = deal_products.id")
        .joins("INNER JOIN deals ON deal_products.deal_id = deals.id")
        .joins("INNER JOIN stages ON deals.stage_id = stages.id")
        .where("(deals.advertiser_id = ? OR deals.agency_id = ?) AND deals.company_id = ? AND deals.open IS TRUE AND deal_products.open IS TRUE", client.id, client.id, company.id)
        .select("deal_product_budgets.*, stages.probability, deals.id as deal_id").to_a

        deal_product_budgets.each do |deal_product_budget|
          daily_budget = (deal_product_budget.budget / 100.0) / (deal_product_budget.end_date.to_date - deal_product_budget.start_date.to_date + 1).to_f
          probability = deal_product_budget.probability

          time_dimensions.each do |time_dimension|

            from = [time_dimension.start_date.to_date, deal_product_budget.start_date.to_date].max
            to = [time_dimension.end_date.to_date, deal_product_budget.end_date.to_date].min
            days = [(to - from) + 1, 0].max
            total_budgets[time_dimension.id] = total_budgets[time_dimension.id] + daily_budget * days * (probability / 100.0)
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