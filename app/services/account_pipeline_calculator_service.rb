class AccountPipelineCalculatorService < BaseService
  def perform
    manage_pipeline_facts
  end

  private

  def manage_pipeline_facts
    clients.each do |client|
      total_budgets = TotalBudgetCalculationService.new(client).perform
      # destroy unused account pipeline facts if there is nothing to calculate for current client
      unless total_budgets.any?
        unused_pipeline_facts = AccountPipelineFact.where(account_dimension_id: client.id, company_id: client.company_id)
        unused_pipeline_facts.destroy_all
      end
      total_budgets.each do |key, value|
        account_pipeline_fact = AccountPipelineFact.find_or_initialize_by(company_id: client.company.id, account_dimension_id: client.id, time_dimension_id: key)
        account_pipeline_fact.pipeline_amount = value
        account_pipeline_fact.save!
      end
    end
  end

  def clients
    @clients ||= Client.joins(:account_dimensions).where(company_id: company_ids)
  end

  def company_ids
    Company.pluck(:id)
  end
end