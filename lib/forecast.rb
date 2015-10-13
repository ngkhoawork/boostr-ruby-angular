class Forecast
  attr_accessor :company, :rows, :time_period

  def initialize(company, rows, time_period)
    self.company = company
    self.rows = rows
    self.time_period = time_period
  end

  def as_json(options={})
    {
      teams: teams,
      stages: stages,
      weighted_pipeline: weighted_pipeline,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota,
      quota: quota
    }
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
