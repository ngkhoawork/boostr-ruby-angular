class Pmps::PmpAggregatedActualSerializer < ActiveModel::Serializer
  attributes(
    :date,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :ad_requests
  )
end
