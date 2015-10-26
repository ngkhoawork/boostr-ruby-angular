class Forecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :rows, :time_period

  def initialize(company, rows, time_period)
    self.company = company
    self.rows = rows
    self.time_period = time_period
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
    @teams ||= rows.map{ |t| ForecastTeam.new(t, time_period) }
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
end
