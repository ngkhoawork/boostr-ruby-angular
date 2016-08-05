class Forecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :teams, :team_members, :start_date, :end_date, :year, :time_period

  # If there is a year, the start_date and end_date are ignored
  def initialize(company, teams, start_date, end_date, year = nil)
    self.company = company
    self.start_date = start_date
    self.end_date = end_date
    self.year = year
    unless year.nil?
      @teams = teams.map do |t|
        quarters.map do |dates|
          ForecastTeam.new(t, dates[:start_date], dates[:end_date], dates[:quarter], year)
        end
      end.flatten
    else
      @teams = teams.map{ |t| ForecastTeam.new(t, start_date, end_date) }
    end
  end

  def cache_key
    parts = []
    teams.each do |team|
      parts << team.cache_key
    end
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
          ForecastMember.new(m, dates[:start_date], dates[:end_date], dates[:quarter])
        end
      end.flatten
    else
      @team_members = company.teams_tree_members.map{ |m| ForecastMember.new(m, start_date, end_date) }
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

  def revenue
    teams.sum(&:revenue)
  end

  def amount
    teams.sum(&:amount)
  end

  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota)
  end

  def new_deals_needed
    sum = 0
    teams.each do |team|
      num = team.new_deals_needed
      if num != 'N/A'
        sum += num
      else
        sum = 'N/A'
        break
      end
    end
    sum
  end

  def quota
    teams.sum(&:quota)
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
end
