class ForecastTeam
  attr_accessor :team

  def initialize(team)
    self.team = team
  end

  def as_json(options={})
    {
      id: team.id,
      name: team.name,
      teams: teams,
      members: members,
      weighted_pipeline: weighted_pipeline,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota
   }
  end

  def teams
    @teams ||= team.children.map{ |t| ForecastTeam.new(t) }
  end

  def members
    @members ||= team.members.map{|m| ForecastMember.new(m) }
  end

  def weighted_pipeline
    teams.sum(&:weighted_pipeline) + members.sum(&:weighted_pipeline)
  end

  def revenue
    teams.sum(&:revenue) + members.sum(&:revenue)
  end

  def amount
    teams.sum(&:amount) + members.sum(&:amount)
  end

  def percent_to_quota
    teams.sum(&:percent_to_quota) + members.sum(&:percent_to_quota)
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota) + members.sum(&:gap_to_quota)
  end


end
