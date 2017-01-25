class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget
  property :deal_stage_log_previous_stage, exec_context: :decorator
  # property :deal_total_budget_change, exec_context: :decorator


  private

  # def deal_total_budget_change
  #   represented.deal_logs.sum(:budget_change)
  # end

  def deal_stage_log_previous_stage
    represented.deal_stage_logs.try(:last).try(:previous_stage).try(:name) || ''
  end

end