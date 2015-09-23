class ForecastTeam
  attr_accessor :team, :time_period

  def initialize(team, time_period)
    self.team = team
    self.time_period = time_period
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
      gap_to_quota: gap_to_quota,
      quota: quota
   }
  end

  def teams
    @teams ||= team.children.map{ |t| ForecastTeam.new(t, time_period) }
  end

  def members
    return @members if defined?(@members)
    @members = team.members.map{|m| ForecastMember.new(m, time_period) }
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
    return 100 unless quota > 0
    amount / quota * 100
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota) + members.sum(&:gap_to_quota)
  end

  def quota
    team.leader ? team.leader.quotas.for_time_period(time_period).sum(:value) : 0
  end
end
