class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget
  property :previous_stage, exec_context: :decorator

  def previous_stage
    represented.try(:previous_stage).try(:name) || ''
  end
end
