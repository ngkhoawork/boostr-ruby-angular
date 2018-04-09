class ProductForecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :teams, :product, :team_members, :start_date, :end_date, :year, :time_period

  # If there is a year, the start_date and end_date are ignored
  def initialize(company, teams, product, start_date, end_date, year = nil)
    self.company = company
    self.product = product
    self.start_date = start_date
    self.end_date = end_date
    self.year = year
    unless year.nil?
      @teams = teams.map do |t|
        quarters.map do |dates|
          ProductForecastTeam.new(t, product, dates[:start_date], dates[:end_date], dates[:quarter], year)
        end
      end.flatten
    else
      @teams = teams.map{ |t| ProductForecastTeam.new(t, product, start_date, end_date) }
    end
  end

  def cache_key
    parts = []
    teams.each do |team|
      parts << team.cache_key
    end
    parts << (product.present? ? product.id : nil)
    stages.each do |stage|
      parts << stage.id
      parts << stage.updated_at
    end
    Digest::MD5.hexdigest(parts.join)
  end

  def team_members
    return @team_members if defined?(@team_members)

    if year.present?
      @team_members = company.teams_tree_members.map do |m|
        quarters.map do |dates|
          ProductForecastMember.new(m, product, dates[:start_date], dates[:end_date], dates[:quarter])
        end
      end.flatten
    else
      @team_members = company.teams_tree_members.map{ |m| ProductForecastMember.new(m, product, start_date, end_date) }
    end
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

  def weighted_pipeline
    teams.sum(&:weighted_pipeline)
  end

  def unweighted_pipeline
    teams.sum(&:unweighted_pipeline)
  end

  def revenue
    teams.sum(&:revenue)
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
    @monthly_weighted_pipeline_by_stage
  end

  def quarterly_weighted_pipeline_by_stage
    return @quarterly_weighted_pipeline_by_stage if defined?(@quarterly_weighted_pipeline_by_stage)
    @quarterly_weighted_pipeline_by_stage = {}
    teams.each do |t|
      t.quarterly_weighted_pipeline_by_stage.each do |stage_id, stage_data|
        @quarterly_weighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |quarter, total|
          @quarterly_weighted_pipeline_by_stage[stage_id][quarter] ||= 0
          @quarterly_weighted_pipeline_by_stage[stage_id][quarter] += total
        end
      end
    end
    @quarterly_weighted_pipeline_by_stage
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
    @monthly_unweighted_pipeline_by_stage
  end

  def quarterly_unweighted_pipeline_by_stage
    return @quarterly_unweighted_pipeline_by_stage if defined?(@quarterly_unweighted_pipeline_by_stage)
    @quarterly_unweighted_pipeline_by_stage = {}
    teams.each do |t|
      t.quarterly_unweighted_pipeline_by_stage.each do |stage_id, stage_data|
        @quarterly_unweighted_pipeline_by_stage[stage_id] ||= {}
        stage_data.each do |quarter, total|
          @quarterly_unweighted_pipeline_by_stage[stage_id][quarter] ||= 0
          @quarterly_unweighted_pipeline_by_stage[stage_id][quarter] += total
        end
      end
    end
    @quarterly_unweighted_pipeline_by_stage
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
    @monthly_revenue
  end

  def quarterly_revenue
    return @quarterly_revenue if defined?(@quarterly_revenue)
    @quarterly_revenue = {}
    teams.each do |t|
      t.quarterly_revenue.each do |quarter, total|
        @quarterly_revenue[quarter] ||= 0
        @quarterly_revenue[quarter] += total
      end
    end
    @quarterly_revenue
  end

  def amount
    teams.sum(&:amount)
  end

  def percent_booked
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota)
  end

  def quota
    teams.sum(&:quota)
  end

  def quarterly_quota
    return @quarterly_quota if defined?(@quarterly_quota)

    @quarterly_quota = {}
    teams.each do |team|
      team.quarterly_quota.each do |quarter, value|
        @quarterly_quota[quarter] ||= 0
        @quarterly_quota[quarter] += value
      end
    end

    @quarterly_quota
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
