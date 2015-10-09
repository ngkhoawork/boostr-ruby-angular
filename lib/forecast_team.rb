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
      parents: parents,
      leader: leader,
      members: members,
      weighted_pipeline: weighted_pipeline,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota,
      quota: quota,
      wow_revenue: wow_revenue,
      wow_weighted_pipeline: wow_weighted_pipeline,
      type: 'team'
   }
  end

  def parents
    return @parents if defined?(@parents)
    @parents = []
    parent = team.parent
    loop do
      break if parent.nil?
      @parents <<  {id: parent.id, name: parent.name}
      parent = parent.parent
    end
    @parents = @parents.reverse
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

  def wow_weighted_pipeline
    teams.sum(&:wow_weighted_pipeline) + members.sum(&:wow_weighted_pipeline) + (leader.try(:wow_weighted_pipeline) || 0)
  end

  def wow_revenue
    teams.sum(&:wow_revenue) + members.sum(&:wow_revenue) + (leader.try(:wow_revenue) || 0)
  end

  def amount
    teams.sum(&:amount) + non_leader_members.sum(&:amount) + (leader.try(:amount) || 0)
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
