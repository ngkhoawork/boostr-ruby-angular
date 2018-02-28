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
    :budget_remaining_loc,
    :run_rate_7_days,
    :run_rate_30_days,
    :pmp_type,
    :product
  )

  def ssp
    object.ssp.serializable_hash(only: [:id, :name]) rescue nil
  end

  def product
    object.product.serializable_hash(only: [:id, :name]) rescue nil
  end
end
