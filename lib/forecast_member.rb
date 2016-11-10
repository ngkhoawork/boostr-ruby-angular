class ForecastMember
  include ActiveModel::SerializerSupport

  delegate :id, to: :member
  delegate :name, to: :member

  attr_accessor :member, :start_date, :end_date, :quarter, :year

  def initialize(member, start_date, end_date, quarter = nil, year = nil)
    self.member = member
    self.start_date = start_date
    self.end_date = end_date
    self.quarter = quarter
    self.year = year
  end

  def is_leader
    member.leader?
  end

  def type
    'member'
  end

  def cache_key
    parts = []
    parts << member.id
    parts << member.updated_at
    parts << start_date
    parts << end_date
    parts << year
    parts << quarter
    # Weighted pipeline
    open_deals.each do |deal|
      parts << deal.id
      parts << deal.updated_at
      parts << deal.stage.id
      parts << deal.stage.updated_at
    end

    # Revenue
    clients.each do |client|
      parts << client.id
      parts << client.updated_at
    end

    ios.each do |io|
      parts << io.id
      parts << io.updated_at
      io.content_fee_product_budgets.each do |content_fee_product_budget|
        parts << content_fee_product_budget.id
        parts << content_fee_product_budget.updated_at
      end

      io.display_line_items.each do |display_line_item|
        parts << display_line_item.id
        parts << display_line_item.updated_at
      end
    end

    # Week over week
    snapshots.each do |snapshot|
      parts << snapshot.id
      parts << snapshot.updated_at
    end
    # Stages?
    stages.each do |stage|
      parts << stage.id
      parts << stage.updated_at
    end
    Digest::MD5.hexdigest(parts.join)
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
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          deal_total += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
        end
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
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          deal_total += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
        end
      end
      @weighted_pipeline_by_stage[deal.stage.id] ||= 0
      @weighted_pipeline_by_stage[deal.stage.id] += deal_total * (deal.stage.probability / 100.0)
    end
    @weighted_pipeline_by_stage
  end

  def unweighted_pipeline_by_stage
    return @unweighted_pipeline_by_stage if defined?(@unweighted_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @unweighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      deal_total = 0
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          deal_total += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
        end
      end
      @unweighted_pipeline_by_stage[deal.stage.id] ||= 0
      @unweighted_pipeline_by_stage[deal.stage.id] += deal_total
    end
    @unweighted_pipeline_by_stage
  end

  def revenue
    return @revenue if defined?(@revenue)

    @revenue = ios.sum do |io|
      io.effective_revenue_budget(member, start_date, end_date)
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

  def percent_to_quota
    # attainment
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_booked
    # attainment
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def gap_to_quota
    quota - amount
  end

  def quota
    @quota ||= member.quotas.for_time_period(start_date, end_date).sum(:value)
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
      @average_deal_size ||= (complete_deals.average(:budget) / 100).round(0)
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

  private

  def client_ids
    @client_ids ||= member.client_members.map(&:client_id)
  end

  def revenues
    @revenues ||= member.company.revenues.where(client_id: client_ids).for_time_period(start_date, end_date).to_a
  end

  def ios
    @ios ||= member.ios.for_time_period(start_date, end_date).to_a
  end

  def clients
    self.member.clients
  end

  def open_deals
    @open_deals ||= member.deals.where(open: true).for_time_period(start_date, end_date).includes(:deal_product_budgets, :stage).to_a
  end

  def complete_deals
    @complete_deals ||= member.deals.active.at_percent(100).closed_in(member.company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= member.deals.active.closed.at_percent(0).closed_in(member.company.deals_needed_calculation_duration)
  end

  def number_of_days(comparer)
    from = [start_date, comparer.start_date].max
    to = [end_date, comparer.end_date].min
    [(to.to_date - from.to_date) + 1, 0].max
  end

  def effective_days(comparer, effecter)
    from = [start_date, comparer.start_date, effecter.from_date].max
    to = [end_date, comparer.end_date, effecter.to_date].min
    [(to.to_date - from.to_date) + 1, 0].max
  end

  def snapshots
    if year
      @snapshots ||= member.snapshots.two_recent_for_year_and_quarter(year, quarter)
    else
      @snapshots ||= member.snapshots.two_recent_for_time_period(start_date, end_date)
    end
  end
end
