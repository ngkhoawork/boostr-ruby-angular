class BudgetChangeSerializer < ActiveModel::Serializer
  cached

  attributes(:id, :name, :advertiser_name, :start_date, :stage_name, :budget, :budget_change, :deal_stage_log_previous_stage)

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

  def deal_stage_log_previous_stage
    ''
  end

  def id
    object.deal.id
  end

  def name
    object.deal.name
  end
end