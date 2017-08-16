class Report::BudgetChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :start_date, :budget, :budget_change, :date

  private

  def id
    object.auditable_id
  end

  def name
    deal.name
  end

  def advertiser_name
    deal.advertiser.name
  end

  def start_date
    deal.start_date
  end

  def budget
    deal.budget
  end

  def budget_change
    object.changed_amount
  end

  def date
    object.created_at rescue nil
  end

  def deal
    @_deal ||= Deal.with_deleted.find(object.auditable_id)
  end
end
