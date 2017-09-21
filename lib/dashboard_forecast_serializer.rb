class DashboardForecastSerializer < ActiveModel::Serializer

  attributes(
    :weighted_pipeline,
    :revenue,
    :amount,
    :percent_to_quota,
    :gap_to_quota,
    :quota,
    :new_deals_needed,
    :stages,
    :weighted_pipeline_by_stage
  )
end

