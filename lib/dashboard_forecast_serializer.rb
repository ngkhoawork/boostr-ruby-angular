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
    :weighted_pipeline_by_stage,
    :time_period_name
  )

  def time_period_name
    object.time_period&.name
  end
end
