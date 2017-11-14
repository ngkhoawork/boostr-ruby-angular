class Pmps::PmpItemSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :deal_id,
    :ssp,
    :budget,
    :budget_loc,
    :budget_delivered,
    :budget_delivered_loc,
    :budget_remaining,
    :budget_remaining_loc
  )

  has_many :pmp_item_daily_actuals, serializer: Pmps::PmpItemDailyActualSerializer

  def ssp
    object.ssp.serializable_hash(only: [:id, :name]) rescue nil
  end
end
