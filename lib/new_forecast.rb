class NewForecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :teams, :team_members, :start_date, :end_date, :time_period, :product_family, :product, :quarter, :year

  # If there is a year, the start_date and end_date are ignored
  def initialize(company, teams, time_period, product_family = nil, product = nil, quarter = nil, year = nil)
    self.company = company
    self.time_period = time_period
    self.start_date = time_period.start_date
    self.end_date = time_period.end_date
    self.product_family = product_family
    self.product = product
    self.quarter = quarter
    self.year = year
    @teams = teams.map{ |t| NewForecastTeam.new(t, time_period, product_family, product, quarter, year) }
  end

  def team_members
    return @team_members if defined?(@team_members)

    @team_members = company.teams_tree_members.map{ |m| NewForecastMember.new(m, time_period, product_family, product, quarter) }
  end

  def stages
    return @stages if defined?(@stages)
    ids = []
    teams.each do |team|
      ids << team.weighted_pipeline_by_stage.keys
    end
    ids = ids.flatten.uniq
    @stages = company.stages.where(id: ids).order(:probability).all
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
    @weighted_pipeline_by_stage
  end

  def weighted_pipeline_by_stage_net
    return @weighted_pipeline_by_stage_net if defined?(@weighted_pipeline_by_stage_net)
    @weighted_pipeline_by_stage_net = {}
    teams.each do |t|
      t.weighted_pipeline_by_stage.each do |stage_id, total|
        @weighted_pipeline_by_stage_net[stage_id] ||= 0
        @weighted_pipeline_by_stage_net[stage_id] += total
      end
    end
    @weighted_pipeline_by_stage_net
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
    @unweighted_pipeline_by_stage
  end

  def unweighted_pipeline_by_stage_net
    return @unweighted_pipeline_by_stage_net if defined?(@unweighted_pipeline_by_stage)
    @unweighted_pipeline_by_stage_net = {}
    teams.each do |t|
      t.unweighted_pipeline_by_stage_net.each do |stage_id, total|
        @unweighted_pipeline_by_stage_net[stage_id] ||= 0
        @unweighted_pipeline_by_stage_net[stage_id] += total
      end
    end
    @unweighted_pipeline_by_stage_net
  end

  def weighted_pipeline
    teams.sum(&:weighted_pipeline)
  end

  def weighted_pipeline_net
    teams.sum(&:weighted_pipeline_net)
  end

  def revenue
    teams.sum(&:revenue)
  end

  def revenue_net
    teams.sum(&:revenue_net)
  end

  def amount
    teams.sum(&:amount)
  end

  def amount_net
    teams.sum(&:amount_net)
  end

  def percent_booked
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def percent_booked_net
    return 100 unless quota > 0
    revenue_net / quota * 100
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_to_quota_net
    return 100 unless quota > 0
    amount_net / quota * 100
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota)
  end

  def gap_to_quota_net
    teams.sum(&:gap_to_quota_net)
  end

  def quota
    teams.sum(&:quota)
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
      @average_deal_size ||= complete_deals.average(:budget).round(0)
    else
      @average_deal_size ||= 0
    end
  end

  def new_deals_needed
    goal = gap_to_quota
    return 0 if goal <= 0
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota / (win_rate * average_deal_size)).ceil
  end

  def complete_deals
    @complete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.at_percent(100).closed_in(company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= Deal.joins(:deal_members).where("deal_members.user_id in (?)", all_members.map{|member| member.id}).active.closed.at_percent(0).closed_in(company.deals_needed_calculation_duration)
  end

  def all_members
    return @all_members if defined?(@all_members)
    @all_members = []
    teams.each do |team|
      @all_members = @all_members + (team.team.all_members.nil? ? []:team.all_members)
    end
    @all_members
  end
end
