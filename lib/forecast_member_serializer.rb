class ForecastMemberSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :revenue,
    :amount,
    :percent_to_quota,
    :gap_to_quota,
    :quota,
    :wow_revenue,
    :wow_weighted_pipeline,
    :is_leader,
    :year,
    :quarter,
    :new_deals_needed,
    :type)
end

