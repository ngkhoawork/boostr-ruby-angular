class QuarterlyForecastTeamSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :stages,
    :type,
    :quarterly_revenue,
    :quarterly_unweighted_pipeline_by_stage,
    :quarterly_weighted_pipeline_by_stage,
    :quarterly_quota
  )

end

