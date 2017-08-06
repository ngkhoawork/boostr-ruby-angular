class Report::BudgetChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :start_date, :stage_name, :budget, :budget_change, :previous_stage, :date

  private

  def id
    object.auditable_id
  end

  def name
    object.auditable.name
  end

  def advertiser_name
    object.auditable.advertiser.name
  end

  def start_date
    object.auditable.start_date
  end

  def stage_name
    ''
  end

  def budget
    object.auditable.budget
  end

  def budget_change
    object.changed_amount
  end

  def previous_stage
    ''
  end

  def date
    object.created_at rescue nil
  end
end
