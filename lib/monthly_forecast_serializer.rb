class MonthlyForecastSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :stages,
    :monthly_revenue,
    :monthly_unweighted_pipeline_by_stage,
    :monthly_weighted_pipeline_by_stage
  )

end

