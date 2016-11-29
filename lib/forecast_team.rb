class ForecastTeam
  include ActiveModel::SerializerSupport

  delegate :id, to: :team
  delegate :name, to: :team

  attr_accessor :team, :start_date, :end_date, :quarter, :year

  def initialize(team, start_date, end_date, quarter = nil, year = nil)
    self.team = team
    self.start_date = start_date
    self.end_date = end_date
    self.quarter = quarter
    self.year = year
  end

  def type
    'team'
  end

  def cache_key
    parts = []
    parts << team.id
    parts << team.updated_at
    parents.each do |parent|
      parts << parent[:id]
      parts << parent[:name]
    end
    teams.each do |team|
      parts << team.cache_key
    end
    if leader
      parts << leader.cache_key
    end
    members.each do |member|
      parts << member.cache_key
    end
    stages.each do |stage|
      parts << stage.id
      parts << stage.updated_at
    end
    Digest::MD5.hexdigest(parts.join)
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
    return @teams if defined?(@teams)

    if quarter.present?
      @teams = team.children.map do |t|
        ForecastTeam.new(t, start_date, end_date, quarter, year)
      end.flatten
    elsif year.present?
      @teams = team.children.map do |t|
        quarters.map do |dates|
          ForecastTeam.new(t, dates[:start_date], dates[:end_date], dates[:quarter])
        end
      end.flatten
    else
      @teams = team.children.map{ |t| ForecastTeam.new(t, start_date, end_date) }
    end
  end

  def leader
    @leader ||= ForecastMember.new(team.leader, start_date, end_date) if team.leader
  end

  def members
    return @members if defined?(@members)

    if quarter.present?
      @members = team.members.map do |m|
        ForecastMember.new(m, start_date, end_date, quarter, year)
      end.flatten
    elsif year.present?
      @members = team.members.map do |m|
        quarters.map do |dates|
          ForecastMember.new(m, dates[:start_date], dates[:end_date], dates[:quarter])
        end
      end.flatten
    else
      @members = team.members.map{ |m| ForecastMember.new(m, start_date, end_date) }
    end
  end

  def quarters
    return @quarters if defined?(@quarters)

    @quarters = []
    @quarters << { start_date: Time.new(year, 1, 1), end_date: Time.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Time.new(year, 4, 1), end_date: Time.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Time.new(year, 7, 1), end_date: Time.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Time.new(year, 10, 1), end_date: Time.new(year, 12, 31), quarter: 4 }
    @quarters
  end

  def non_leader_members
    @non_leader_members ||= members.reject{ |m| m.member.leader? }
  end

  def stages
    return @stages if defined?(@stages)
    ids = weighted_pipeline_by_stage.keys
    @stages = team.company.stages.where(id: ids).order(:probability).all
  end

  def weighted_pipeline_by_stage
    return @weighted_pipeline_by_stage if defined?(@weighted_pipeline_by_stage)
    @weighted_pipeline_by_stage = {}
    teams.each do |t|
      t.weighted_pipeline_by_stage.each do |stage_id, total|
        @weighted_pipeline_by_stage[stage_id] ||= 0
        @weighted_pipeline_by_stage[stage_id] += total
      end
    end
    members.each do |m|
      m.weighted_pipeline_by_stage.each do |stage_id, total|
        @weighted_pipeline_by_stage[stage_id] ||= 0
        @weighted_pipeline_by_stage[stage_id] += total
      end
    end
    if leader
      leader.weighted_pipeline_by_stage.each do |stage_id, total|
        @weighted_pipeline_by_stage[stage_id] ||= 0
        @weighted_pipeline_by_stage[stage_id] += total
      end
    end
    @weighted_pipeline_by_stage
  end

  def weighted_pipeline
    teams.sum(&:weighted_pipeline) + members.sum(&:weighted_pipeline) + (leader.try(:weighted_pipeline) || 0)
  end

  def unweighted_pipeline_by_stage
    return @unweighted_pipeline_by_stage if defined?(@unweighted_pipeline_by_stage)
    @unweighted_pipeline_by_stage = {}
    teams.each do |t|
      t.unweighted_pipeline_by_stage.each do |stage_id, total|
        @unweighted_pipeline_by_stage[stage_id] ||= 0
        @unweighted_pipeline_by_stage[stage_id] += total
      end
    end
    members.each do |m|
      m.unweighted_pipeline_by_stage.each do |stage_id, total|
        @unweighted_pipeline_by_stage[stage_id] ||= 0
        @unweighted_pipeline_by_stage[stage_id] += total
      end
    end
    if leader
      leader.unweighted_pipeline_by_stage.each do |stage_id, total|
        @unweighted_pipeline_by_stage[stage_id] ||= 0
        @unweighted_pipeline_by_stage[stage_id] += total
      end
    end
    @unweighted_pipeline_by_stage
  end

  def revenue
    teams.sum(&:revenue) + members.sum(&:revenue) + (leader.try(:revenue) || 0)
  end

  def monthly_weighted_pipeline_by_stage
    return @monthly_weighted_pipeline_by_stage if defined?(@monthly_weighted_pipeline_by_stage)
    @monthly_weighted_pipeline_by_stage = {}
    teams.each do |t|
      t.monthly_weighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_weighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_weighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_weighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    members.each do |m|
      m.monthly_weighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_weighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_weighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_weighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    if leader
      leader.monthly_weighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_weighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_weighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_weighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    @monthly_weighted_pipeline_by_stage
  end

  def monthly_unweighted_pipeline_by_stage
    return @monthly_unweighted_pipeline_by_stage if defined?(@monthly_unweighted_pipeline_by_stage)
    @monthly_unweighted_pipeline_by_stage = {}
    teams.each do |t|
      t.monthly_unweighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_unweighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_unweighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_unweighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    members.each do |m|
      m.monthly_unweighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_unweighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_unweighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_unweighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    if leader
      leader.monthly_unweighted_pipeline_by_stage.each do |stage_id, stage_data|
        @monthly_unweighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |month, total|
          @monthly_unweighted_pipeline_by_stage[stage_id][month] ||= 0
          @monthly_unweighted_pipeline_by_stage[stage_id][month] += total
        end
      end
    end
    @monthly_unweighted_pipeline_by_stage
  end

  def monthly_revenue
    return @monthly_revenue if defined?(@monthly_revenue)
    @monthly_revenue = {}
    teams.each do |t|
      t.monthly_revenue.each do |month, total|
        @monthly_revenue[month] ||= 0
        @monthly_revenue[month] += total
      end
    end
    members.each do |m|
      m.monthly_revenue.each do |month, total|
        @monthly_revenue[month] ||= 0
        @monthly_revenue[month] += total
      end
    end
    if leader
      leader.monthly_revenue.each do |month, total|
        @monthly_revenue[month] ||= 0
        @monthly_revenue[month] += total
      end
    end
    @monthly_revenue
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

  def percent_booked
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def gap_to_quota
    quota - amount
  end

  def quota
    leader.try(:quota) || 0
  end

  def win_rate
    if (incomplete_deals.count + complete_deals.count) > 0
      @win_rate ||= (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
    else
      @win_rate ||= 0.0
    end
  end

  def average_deal_size
    if complete_deals.count > 0
      @average_deal_size ||= (complete_deals.average(:budget) / 100).round(0)
    else
      @average_deal_size ||= 0
    end
  end

  def new_deals_needed
    goal = gap_to_quota
    return 0 if goal <= 0
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota / (win_rate * average_deal_size)).ceil
    # return 0 if gap_to_quota <= 0
    # members_gap_to_quota = 0
    # new_deals = 0
    #
    # teams.each do |team|
    #   num = team.new_deals_needed
    #   members_gap_to_quota += team.gap_to_quota
    #   if num != 'N/A'
    #     new_deals += num
    #   end
    # end
    # return 'N/A' if new_deals == 'N/A'
    #
    # members.each do |member|
    #   next if leader and member.member == leader.member
    #   members_gap_to_quota += member.gap_to_quota
    #   if member.new_deals_needed != 'N/A'
    #     new_deals += member.new_deals_needed
    #   end
    #
    # end
    # return 'N/A' if new_deals == 'N/A'

    # leader_gap_to_quota = gap_to_quota - members_gap_to_quota
    #
    # if leader_gap_to_quota > 0
    #   if leader.win_rate > 0 and leader.average_deal_size > 0
    #     new_deals += (leader_gap_to_quota / (leader.win_rate * leader.average_deal_size)).ceil
    #   else
    #     return 'N/A'
    #   end
    # end
    # new_deals
  end

  def complete_deals
    @complete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.at_percent(100).closed_in(team.company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.closed.at_percent(0).closed_in(team.company.deals_needed_calculation_duration)
  end

  def all_teammembers
    (team.all_members.nil? ? []:team.all_members) + (team.all_leaders.nil? ? []:team.all_leaders)
  end

  def all_members
    (team.all_members.nil? ? []:team.all_members)
  end
end
