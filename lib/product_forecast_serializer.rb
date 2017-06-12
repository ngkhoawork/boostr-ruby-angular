class ProductForecastSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :product,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :unweighted_pipeline,
    :revenue,
  )

  def teams
    tteams ||= object.teams.map do |team|
      ForecastTeamSerializer.new(team, root: false)
    end
  end

end

