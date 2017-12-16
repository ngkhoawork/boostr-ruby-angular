class Pmps::PmpItemDailyActualSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :pmp_item_id,
    :ssp_deal_id,
    :date,
    :ad_unit,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :render_rate,
    :bids,
    :product
  )

  def ssp_deal_id
    object.pmp_item.ssp_deal_id rescue nil
  end

  def product
    object.product.serializable_hash(only: [:id, :name]) rescue nil
  end
end
