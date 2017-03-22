class AccountPipelineCalculatorService < BaseService
  def perform
    clients.each do |client|
      if client.account_dimensions.any?
        deal_product_budgets = DpBudgetQuery.new(client_id: client.id, company_id: client.company_id).all
        # destroy unused account pipeline facts if there is nothing to calculate for current client
        unless deal_product_budgets.any?
          unused_pipeline_facts = AccountPipelineFact.where(account_dimension_id: client.id, company_id: client.company_id)
          unused_pipeline_facts.destroy_all
        end
        total_budgets = calculate_total_budgets(deal_product_budgets)
        total_budgets.each do |key, value|
          account_pipeline_fact = AccountPipelineFact.find_or_initialize_by(company_id: client.company.id, account_dimension_id: client.id, time_dimension_id: key)
          account_pipeline_fact.pipeline_amount = value
          account_pipeline_fact.save!
        end
      end
    end
  end

  def calculate_total_budgets(deal_product_budgets)
    total_budgets = {}
    deal_product_budgets.each do |deal_product_budget|
      daily_budget = (deal_product_budget.budget.present? ? deal_product_budget.budget : 0) / (deal_product_budget.end_date.to_date - deal_product_budget.start_date.to_date + 1).to_f
      probability = deal_product_budget.stage_prob.present? ? deal_product_budget.stage_prob : 0

      time_dimensions.each do |time_dimension|
        if time_dimension.start_date <= deal_product_budget.end_date && time_dimension.end_date >= deal_product_budget.start_date
          from = [time_dimension.start_date.to_date, deal_product_budget.start_date.to_date].max
          to = [time_dimension.end_date.to_date, deal_product_budget.end_date.to_date].min
          days = [(to - from) + 1, 0].max
          total_budgets[time_dimension.id] = daily_budget * days * (probability / 100.0)
        end
      end
    end
    total_budgets
  end

  def time_dimensions
    @time_dimenstions ||= TimeDimension.all
  end

  def clients
    @clients ||= Client.includes(:account_dimensions).where(company_id: company_ids)
  end

  def company_ids
    Company.pluck(:id)
  end
end