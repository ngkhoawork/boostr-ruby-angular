class BudgetChangeSerializer < ActiveModel::Serializer
  cached

  attributes :id, :name, :advertiser_name, :start_date, :stage_name, :budget, :budget_change, :previous_stage, :date

  private

  def advertiser_name
    object.deal.advertiser_name
  end

  def start_date
    object.deal.start_date
  end

  def stage_name
    ''
  end

  def budget
    object.deal.budget
  end

  def previous_stage
    ''
  end

  def id
    object.deal.id
  end

  def name
    object.deal.name
  end

  def date
    object.deal_stage_logs.ordered_by_created_at.first.created_at.to_date rescue nil
  end
end
