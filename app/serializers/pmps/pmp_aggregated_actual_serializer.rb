class Pmps::PmpAggregatedActualSerializer < ActiveModel::Serializer
  attributes(
    :date,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :render_rate,
    :bids
  )
end
