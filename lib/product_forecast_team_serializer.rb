class ProductForecastTeamSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :product,
    :stages,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :weighted_pipeline,
    :unweighted_pipeline,
    :revenue,
    :type
  )

  def teams
    @teams ||= object.teams.map do |team|
      ForecastTeamSerializer.new(team, root: false)
    end
  end

  def leader
    @leader ||= ForecastMemberSerializer.new(object.leader, root: false) if object.leader
  end

  def members
    @members ||= object.members.map do |member|
      ForecastMemberSerializer.new(member, root: false)
    end
  end

  def year_value
    object.year || object.start_date.year rescue nil
  end

  def quarter_number
    if object.start_date.present? && object.end_date.present? && (object.end_date - object.start_date).to_i < 100
      1 + ((object.start_date.month - 1)/3).to_i
    end
  end
end
