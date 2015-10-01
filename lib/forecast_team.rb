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
      leader: leader,
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

  def leader
    @leader ||= ForecastMember.new(team.leader, time_period) if team.leader
  end

  def members
    @members ||= team.members.map{ |m| ForecastMember.new(m, time_period) }
  end

  def non_leader_members
    @non_leader_members ||= members.reject{ |m| m.member.leader? }
  end

  def weighted_pipeline
    teams.sum(&:weighted_pipeline) + members.sum(&:weighted_pipeline) + (leader.try(:weighted_pipeline) || 0)
  end

  def revenue
    teams.sum(&:revenue) + members.sum(&:revenue) + (leader.try(:revenue) || 0)
  end

  def amount
    teams.sum(&:amount) + non_leader_members.sum(&:amount) + (leader.try(:weighted_pipeline) || 0) + (leader.try(:revenue) || 0)
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota) + members.sum(&:gap_to_quota)
  end

  def quota
    leader.try(:quota) || 0
  end
end
