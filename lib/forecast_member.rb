class ForecastMember
  attr_accessor :member, :time_period

  def initialize(member, time_period)
    self.member = member
    self.time_period = time_period
  end

  def as_json(options={})
    {
      id: member.id,
      name: member.name,
      stages: stages,
      weighted_pipeline: weighted_pipeline,
      weighted_pipeline_by_stage: weighted_pipeline_by_stage,
      revenue: revenue,
      amount: amount,
      percent_to_quota: percent_to_quota,
      gap_to_quota: gap_to_quota,
      quota: quota,
      wow_revenue: wow_revenue,
      wow_weighted_pipeline: wow_weighted_pipeline,
      is_leader: member.leader?,
      type: 'member'
    }
  end

  def stages
    return @stages if defined?(@stages)
    ids = weighted_pipeline_by_stage.keys
    @stages = member.company.stages.where(id: ids).order(:probability).all.to_a
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @weighted_pipeline = open_deals.sum do |deal|
      deal_total = 0
      deal.deal_products.for_time_period(time_period).each do |deal_product|
        deal_total += deal_product.daily_budget * number_of_days(deal_product) * (deal_shares[deal.id]/100.0)
      end
      deal_total * (deal.stage.probability / 100.0)
    end
  end

  def weighted_pipeline_by_stage
    return @weighted_pipeline_by_stage if defined?(@weighted_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @weighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      deal_total = 0
      deal.deal_products.for_time_period(time_period).each do |deal_product|
        deal_total += deal_product.daily_budget * number_of_days(deal_product) * (deal_shares[deal.id]/100.0)
      end
      @weighted_pipeline_by_stage[deal.stage.id] ||= 0
      @weighted_pipeline_by_stage[deal.stage.id] += deal_total * (deal.stage.probability / 100.0)
    end
    @weighted_pipeline_by_stage
  end

  def revenue
    return @revenue if defined?(@revenue)

    client_shares = {}
    member.client_members.each do |mem|
      client_shares[mem.client_id] = mem.share
    end

    @revenue = revenues.sum do |rev|
      rev.daily_budget * number_of_days(rev) * (client_shares[rev.client_id]/100.0)
    end
  end

  def wow_weighted_pipeline
    snapshots.first.weighted_pipeline - snapshots.last.weighted_pipeline rescue 0
  end

  def wow_revenue
    snapshots.first.revenue - snapshots.last.revenue rescue 0
  end

  def amount
    @amount ||= weighted_pipeline + revenue
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
    @revenues ||= member.company.revenues.where(client_id: client_ids).for_time_period(time_period).to_a
  end

  def open_deals
    @open_deals ||= member.deals.joins(:stage).where('stages.open IS true').for_time_period(time_period).includes(:deal_products).to_a
  end

  def number_of_days(comparer)
    from = [time_period.start_date, comparer.start_date].max
    to = [time_period.end_date, comparer.end_date].min
    (to.to_date - from.to_date) + 1
  end

  def snapshots
    @snapshots ||= member.snapshots.two_recent_for_time_period(time_period)
  end
end
