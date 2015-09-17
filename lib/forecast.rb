class Forecast
  attr_accessor :rows

  def initialize(rows)
    self.rows = rows
  end

  def as_json(options={})
    {
      teams: teams,
      weighted_pipeline: weighted_pipeline,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota
    }
  end

  def teams
    @teams ||= rows.map{ |t| ForecastTeam.new(t) }
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
    teams.sum(&:percent_to_quota)
  end

  def gap_to_quota
    teams.sum(&:gap_to_quota)
  end
end
