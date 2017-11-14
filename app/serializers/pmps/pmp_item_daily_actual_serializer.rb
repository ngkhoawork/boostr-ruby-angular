class Pmps::PmpItemDailyActualSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :pmp_item_id,
    :date,
    :ad_unit,
    :price,
    :revenue,
    :revenue_loc,
    :impressions
  )

end
