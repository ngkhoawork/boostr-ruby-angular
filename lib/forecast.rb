class Forecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :rows, :start_date, :end_date, :year

  def initialize(company, rows, start_date, end_date, year = nil)
    self.company = company
    self.rows = rows
    self.start_date = start_date
    self.end_date = end_date
    self.year = year
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

  def teams
    return @teams if defined?(@teams)

    if year.present?
      @teams = rows.map do |t|
        quarters.map do |dates|
          ForecastTeam.new(t, dates[:start_date], dates[:end_date], dates[:quarter])
        end
      end.flatten
    else
      @teams = rows.map{ |t| ForecastTeam.new(t, start_date, end_date) }
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
