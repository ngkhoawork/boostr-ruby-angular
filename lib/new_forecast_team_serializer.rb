class NewForecastTeamSerializer < ActiveModel::Serializer
  # cached

  # delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :weighted_pipeline_by_stage,
    :weighted_pipeline_by_stage_net,
    :unweighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage_net,
    :weighted_pipeline,
    :weighted_pipeline_net,
    :revenue,
    :revenue_net,
    :amount,
    :amount_net,
    :percent_to_quota,
    :percent_to_quota_net,
    :percent_booked,
    :percent_booked_net,
    :gap_to_quota,
    :gap_to_quota_net,
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
