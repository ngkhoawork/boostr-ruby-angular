class ForecastMember
  attr_accessor :member

  def initialize(member)
    self.member = member
  end

  def as_json(options={})
    {
      id: member.id,
      full_name: member.full_name,
      weighted_pipeline: weighted_pipeline,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota
    }
  end

  def weighted_pipeline
    0
  end

  def revenue
    0
  end

  def amount
    0
  end

  def percent_to_quota
    0
  end

  def gap_to_quota
    0
  end
end
