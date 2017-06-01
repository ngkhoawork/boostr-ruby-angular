class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget
  property :previous_stage, exec_context: :decorator
  property :date, exec_context: :decorator

  def previous_stage
    represented.try(:previous_stage).try(:name) || ''
  end

  def date
    represented.deal_stage_logs.ordered_by_created_at.first.created_at.to_date rescue nil
  end
end
