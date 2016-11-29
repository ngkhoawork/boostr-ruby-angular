class MonthlyForecastMemberSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :stages,
    :monthly_revenue,
    :monthly_unweighted_pipeline_by_stage,
    :monthly_weighted_pipeline_by_stage,
    :type
  )
end

