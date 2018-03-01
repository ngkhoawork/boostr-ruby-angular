class NewForecastMemberSerializer < ActiveModel::Serializer
  # cached

  # delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :revenue,
    :amount,
    :weighted_pipeline_net,
    :weighted_pipeline_by_stage_net,
    :unweighted_pipeline_by_stage_net,
    :revenue_net,
    :amount_net,
    :percent_to_quota,
    :percent_to_quota_net,
    :percent_booked,
    :percent_booked_net,
    :gap_to_quota,
    :gap_to_quota_net,
    :quota,
    :quota_net,
    :quarter,
    :year,
    :wow_revenue,
    :wow_weighted_pipeline,
    :is_leader,
    :new_deals_needed,
    :type)
end

