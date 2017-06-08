class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget
  property :previous_stage, exec_context: :decorator
  property :date, exec_context: :decorator

  def previous_stage
    represented.try(:previous_stage).try(:name) || ''
  end

  def date
    deal_date.to_date rescue represented.created_at
  end

  private

  def deal_date
    won_or_lost? ? represented.closed_at : represented.created_at
  end

  def won_or_lost?
    represented.closed_lost? || represented.closed_won?
  end
end
