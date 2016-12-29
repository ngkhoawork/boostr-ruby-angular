class DashboardForecastSerializer < ActiveModel::Serializer
  cached

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

  def cache_key
    object.try(:cache_key)
  end
end

