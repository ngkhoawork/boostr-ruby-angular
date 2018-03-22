class NewForecastSerializer < ActiveModel::Serializer
  # cached

  # delegate :cache_key, to: :object

  attributes(
    :time_period,
    :teams,
    :team_members,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_net,
    :weighted_pipeline_by_stage,
    :weighted_pipeline_by_stage_net,
    :unweighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage_net,
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
    :quarter,
    :year,
    :new_deals_needed
  )

  def teams
    tteams ||= object.teams.map do |team|
      NewForecastTeamSerializer.new(team, root: false)
    end
  end

end

