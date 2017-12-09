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
    :bids
  )

  def ssp_deal_id
    object.pmp_item.ssp_deal_id
  end
end
