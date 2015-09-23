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
      gap_to_quota: gap_to_quota,
      quota: quota
    }
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @weighted_pipeline = open_deals.sum do |deal|
      deal_total = 0
      deal.deal_products.each do |deal_product|
        if deal_product.start_date < time_period.end_date && deal_product.end_date > time_period.start_date
          from = [time_period.start_date, deal_product.start_date].max
          to = [time_period.end_date, deal_product.end_date].min
          num_days = (to.to_date - from.to_date) + 1
          deal_total += deal_product.daily_budget * num_days * (deal_shares[deal.id]/100.0)
        end
      end
      deal_total * (deal.stage.probability / 100.0)
    end
  end

  def revenue
    return @revenue if defined?(@revenue)

    client_shares = {}
    member.client_members.each do |mem|
      client_shares[mem.client_id] = mem.share
    end

    @revenue = revenues.sum do |rev|
      from = [time_period.start_date, rev.start_date].max
      to = [time_period.end_date, rev.end_date].min
      num_days = (to.to_date - from.to_date) + 1
      rev.daily_budget * num_days * (client_shares[rev.client_id]/100.0)
    end
  end

  def amount
    weighted_pipeline + revenue
  end

  # attainment
  def percent_to_quota
    return 100 unless quota > 0
    amount / quota * 100
  end

  def gap_to_quota
    quota - amount
  end

  def quota
    @quota ||= member.quotas.for_time_period(time_period).sum(:value)
  end

  private

  def client_ids
    @client_ids ||= member.client_members.map(&:client_id)
  end

  def revenues
    @revenues ||= member.company.revenues.where(client_id: client_ids).where('start_date <= ? AND end_date >= ?', time_period.end_date, time_period.start_date).to_a
  end

  def open_deals
    @open_deals ||= member.deals.joins(:stage).where('stages.open IS true').where('deals.start_date <= ? AND deals.end_date >= ?', time_period.end_date, time_period.start_date).includes(:deal_products).to_a
  end
end