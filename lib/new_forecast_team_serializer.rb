class NewForecastTeamSerializer < ActiveModel::Serializer
  # cached

  # delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :weighted_pipeline,
    :revenue,
    :amount,
    :percent_to_quota,
    :percent_booked,
    :gap_to_quota,
    :quota,
    :wow_revenue,
    :wow_weighted_pipeline,
    :type,
    :quarter,
    :year,
    :teams,
    :leader,
    :members,
    :stages,
    :all_teammembers,
    :new_deals_needed,
  )

end
