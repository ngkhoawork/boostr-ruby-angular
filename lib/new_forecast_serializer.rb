class NewForecastSerializer < ActiveModel::Serializer
  # cached

  # delegate :cache_key, to: :object

  attributes(
    :time_period,
    :teams,
    :team_members,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :revenue,
    :amount,
    :percent_to_quota,
    :percent_booked,
    :gap_to_quota,
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

