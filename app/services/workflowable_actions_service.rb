class WorkflowableActionsService < BaseService
  def perform
    return_actionable_configs
  end

  def return_actionable_configs
    ApiConfiguration.where(company_id: company_id).switched_on.select(&:workflowable?)
  end
end
