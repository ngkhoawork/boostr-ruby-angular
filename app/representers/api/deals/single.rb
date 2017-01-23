class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget, :stage_id
  property :deal_stage_log_previous_stage_id, exec_context: :decorator

  private

  def deal_stage_log_previous_stage_id
    represented.deal_stage_logs.try(:last).try(:previous_stage_id) || ''
  end

end