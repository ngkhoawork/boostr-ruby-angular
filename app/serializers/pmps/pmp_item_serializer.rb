class Pmps::PmpItemSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :ssp_deal_id,
    :ssp,
    :budget,
    :budget_loc,
    :budget_delivered,
    :budget_delivered_loc,
    :budget_remaining,
    :budget_remaining_loc
  )

  def ssp
    object.ssp.serializable_hash(only: [:id, :name]) rescue nil
  end
end
