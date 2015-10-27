class ForecastSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :teams,
    :stages,
    :weighted_pipeline,
    :revenue,
    :amount,
    :percent_to_quota,
    :gap_to_quota,
    :quota
  )

  def teams
    tteams ||= object.teams.map do |team|
      ForecastTeamSerializer.new(team, root: false)
    end
  end

end

