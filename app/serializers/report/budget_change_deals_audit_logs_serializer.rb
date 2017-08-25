class Report::BudgetChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :advertiser_name, :start_date, :budget, :budget_change, :date, :old_value, :new_value

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
    number_to_currency(deal.budget, precision: 0)
  end

  def budget_change
    object.changed_amount > 0 ? positive_budget_change : "(#{negative_budget_change})"
  end

  def date
    object.created_at rescue nil
  end

  def old_value
    number_to_currency(object.old_value, precision: 0)
  end

  def new_value
    number_to_currency(object.new_value, precision: 0)
  end

  def deal
    @_deal ||= Deal.with_deleted.find(object.auditable_id)
  end

  def positive_budget_change
    number_to_currency(object.changed_amount, precision: 0)
  end

  def negative_budget_change
    number_to_currency(object.changed_amount.abs, precision: 0)
  end
end
