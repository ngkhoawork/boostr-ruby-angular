class ForecastMember
  attr_accessor :member, :time_period

  def initialize(member, time_period)
    self.member = member
    self.time_period = time_period
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

  # For the time period
  # Find all of the revenue items where the client id matches a client that the user is a member of
  # Take the daily budget amount and apply it to the time period limiting by the start and end dates of the revenue
  # Take only the user's share from that daily budget amount
  def revenue
    client_ids = member.client_members.map(&:client_id)
    client_shares = {}
    member.client_members.each do |mem|
      client_shares[mem.client_id] = mem.share
    end

    # TODO, filter by the start and end date inclusively
    revenues = member.company.revenues.where(client_id: client_ids).where('start_date <= ? AND end_date >= ?', time_period.end_date, time_period.start_date).to_a

    total = 0

    revenues.each do |rev|
      daily_budget_amount = rev.daily_budget
      from = (time_period.start_date > rev.start_date) ? time_period.start_date : rev.start_date
      to = (time_period.end_date < rev.end_date) ? time_period.end_date : rev.end_date
      num_days = (to.to_date - from.to_date) + 1
      total += daily_budget_amount * num_days * (client_shares[rev.client_id]/100.0)
    end

    total
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
