class QuarterlyForecastSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :stages,
    :quarterly_revenue,
    :quarterly_weighted_pipeline_by_stage,
    :quarterly_unweighted_pipeline_by_stage,
    :quarterly_quota
  )

end

