class ForecastMember
  include ActiveModel::SerializerSupport

  delegate :id, to: :member
  delegate :name, to: :member

  attr_accessor :member, :start_date, :end_date, :quarter, :year, :time_period

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
        display_line_item.display_line_item_budgets.each do |display_line_item_budget|
          parts << display_line_item_budget.id
          parts << display_line_item_budget.updated_at
        end
      end

      io.io_members.each do |io_member|
        parts << io_member.id
        parts << io_member.updated_at
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

  def monthly_weighted_pipeline_by_stage
    return @weighted_monthly_pipeline_by_stage if defined?(@weighted_monthly_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end


    @monthly_weighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      @monthly_weighted_pipeline_by_stage[deal.stage.id] ||= {}
      months.each do |month_row|
        @monthly_weighted_pipeline_by_stage[deal.stage.id][month_row[:start_date].strftime("%b-%y")] ||= 0
      end
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          @monthly_weighted_pipeline_by_stage[deal.stage.id][deal_product_budget.start_date.strftime("%b-%y")] += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0) * (deal.stage.probability / 100.0)
        end
      end
    end
    @monthly_weighted_pipeline_by_stage
  end

  def quarterly_weighted_pipeline_by_stage
    return @weighted_quarterly_pipeline_by_stage if defined?(@weighted_quarterly_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end


    @quarterly_weighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      @quarterly_weighted_pipeline_by_stage[deal.stage.id] ||= {}
      quarters.each do |quarter_row|
        @quarterly_weighted_pipeline_by_stage[deal.stage.id]['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] ||= 0
      end
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          @quarterly_weighted_pipeline_by_stage[deal.stage.id]['q' + ((deal_product_budget.start_date.month - 1) / 3 + 1).to_s + '-' + deal_product_budget.start_date.year.to_s] += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0) * (deal.stage.probability / 100.0)
        end
      end
    end
    @quarterly_weighted_pipeline_by_stage
  end

  def monthly_unweighted_pipeline_by_stage
    return @monthly_unweighted_pipeline_by_stage if defined?(@monthly_unweighted_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @monthly_unweighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      @monthly_unweighted_pipeline_by_stage[deal.stage.id] ||= {}
      months.each do |month_row|
        @monthly_unweighted_pipeline_by_stage[deal.stage.id][month_row[:start_date].strftime("%b-%y")] ||= 0
      end
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          @monthly_unweighted_pipeline_by_stage[deal.stage.id][deal_product_budget.start_date.strftime("%b-%y")] += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
        end
      end

    end
    @monthly_unweighted_pipeline_by_stage
  end

  def quarterly_unweighted_pipeline_by_stage
    return @quarterly_unweighted_pipeline_by_stage if defined?(@quarterly_unweighted_pipeline_by_stage)

    deal_shares = {}
    member.deal_members.each do |mem|
      deal_shares[mem.deal_id] = mem.share
    end

    @quarterly_unweighted_pipeline_by_stage = {}

    open_deals.each do |deal|
      @quarterly_unweighted_pipeline_by_stage[deal.stage.id] ||= {}
      quarters.each do |quarter_row|
        @quarterly_unweighted_pipeline_by_stage[deal.stage.id]['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] ||= 0
      end
      deal.deal_products.open.each do |deal_product|
        deal_product.deal_product_budgets.for_time_period(start_date, end_date).each do |deal_product_budget|
          @quarterly_unweighted_pipeline_by_stage[deal.stage.id]['q' + ((deal_product_budget.start_date.month - 1) / 3 + 1).to_s + '-' + deal_product_budget.start_date.year.to_s] += deal_product_budget.daily_budget * number_of_days(deal_product_budget) * (deal_shares[deal.id]/100.0)
        end
      end

    end
    @quarterly_unweighted_pipeline_by_stage
  end

  def revenue
    return @revenue if defined?(@revenue)

    @revenue = ios.sum do |io|
      io.effective_revenue_budget(member, start_date, end_date)
    end
  end

  def monthly_revenue
    return @monthly_revenue if defined?(@monthly_revenue)

    @monthly_revenue = {}
    months.each do |month_row|
      @monthly_revenue[month_row[:start_date].strftime("%b-%y")] = 0
    end
    ios.each do |io|
      io_member = io.io_members.find_by(user_id: member.id)
      share = io_member.share
      io.content_fees.each do |content_fee_item|
        content_fee_item.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget_item|
          @monthly_revenue[content_fee_product_budget_item.start_date.strftime("%b-%y")] += content_fee_product_budget_item.corrected_daily_budget(io.start_date, io.end_date) * effective_days(io_member, [content_fee_product_budget_item]) * (share/100.0)
        end
      end
      io.display_line_items.each do |display_line_item|
        ave_run_rate = display_line_item.ave_run_rate
        months.each do |month_row|
          from = [start_date, display_line_item.start_date, io_member.from_date, month_row[:start_date]].max
          to = [end_date, display_line_item.end_date, io_member.to_date, month_row[:end_date]].min
          no_of_days = [(to.to_date - from.to_date) + 1, 0].max
          in_budget_days = 0
          in_budget_total = 0
          display_line_item.display_line_item_budgets.each do |display_line_item_budget|
            in_from = [start_date, display_line_item.start_date, io_member.from_date, display_line_item_budget.start_date, month_row[:start_date]].max
            in_to = [end_date, display_line_item.end_date, io_member.to_date, display_line_item_budget.end_date, month_row[:end_date]].min
            in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
            in_budget_days += in_days
            in_budget_total += display_line_item_budget.daily_budget * in_days * (share/100.0)
          end
          @monthly_revenue[month_row[:start_date].strftime("%b-%y")] += in_budget_total + ave_run_rate * (no_of_days - in_budget_days) * (share/100.0)
        end
      end
    end

    @monthly_revenue
  end

  def quarterly_revenue
    return @quarterly_revenue if defined?(@quarterly_revenue)

    @quarterly_revenue = {}
    quarters.each do |quarter_row|
      @quarterly_revenue['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] = 0
    end
    ios.each do |io|
      io_member = io.io_members.find_by(user_id: member.id)
      share = io_member.share
      io.content_fees.each do |content_fee_item|
        content_fee_item.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget_item|
          @quarterly_revenue['q' + ((content_fee_product_budget_item.start_date.month - 1) / 3 + 1).to_s + '-' + content_fee_product_budget_item.start_date.year.to_s] += content_fee_product_budget_item.corrected_daily_budget(io.start_date, io.end_date) * effective_days(io_member, [content_fee_product_budget_item]) * (share/100.0)
        end
      end
      io.display_line_items.each do |display_line_item|
        ave_run_rate = display_line_item.ave_run_rate
        quarters.each do |quarter_row|
          from = [start_date, display_line_item.start_date, io_member.from_date, quarter_row[:start_date]].max
          to = [end_date, display_line_item.end_date, io_member.to_date, quarter_row[:end_date]].min
          no_of_days = [(to.to_date - from.to_date) + 1, 0].max
          in_budget_days = 0
          in_budget_total = 0
          display_line_item.display_line_item_budgets.each do |display_line_item_budget|
            in_from = [start_date, display_line_item.start_date, io_member.from_date, display_line_item_budget.start_date, quarter_row[:start_date]].max
            in_to = [end_date, display_line_item.end_date, io_member.to_date, display_line_item_budget.end_date, quarter_row[:end_date]].min
            in_days = [(in_to.to_date - in_from.to_date) + 1, 0].max
            in_budget_days += in_days
            in_budget_total += display_line_item_budget.daily_budget * in_days * (share/100.0)
          end
          @quarterly_revenue['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] += in_budget_total + ave_run_rate * (no_of_days - in_budget_days) * (share/100.0)
        end
      end
    end

    @quarterly_revenue
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
    @quota ||= member.total_gross_quotas(start_date, end_date)
  end

  def quarterly_quota
    return @quarterly_quota if defined?(@quarterly_quota)

    @quarterly_quota = {}
    quarters.each do |quarter_row|
      @quarterly_quota['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] = member.total_gross_quotas(quarter_row[:start_date], quarter_row[:end_date])
    end

    @quarterly_quota
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
      @average_deal_size ||= complete_deals.average(:budget).round(0)
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

  def effective_days(effecter, objects)
    from = [start_date]
    to = [end_date]
    from += objects.collect{ |object| object.start_date }
    to += objects.collect{ |object| object.end_date }

    if effecter.present? && effecter.from_date && effecter.to_date
      from << effecter.from_date
      to << effecter.to_date
    end
    [(to.min.to_date - from.max.to_date) + 1, 0].max.to_f
  end

  def common_days(effector, comparer_list)
    from = [effector.from_date]
    to = [effector.to_date]
    comparer_list.each do |item|
      from << item.start_date
      to << item.end_date
    end
    [(to.min.to_date - from.max.to_date) + 1, 0].max
  end

  def snapshots
    if year
      @snapshots ||= member.snapshots.two_recent_for_year_and_quarter(year, quarter)
    else
      @snapshots ||= member.snapshots.two_recent_for_time_period(start_date, end_date)
    end
  end

  def months
    return @months if defined?(@months)

    @months = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
    @months
  end

  def quarters
    return @quarters if defined?(@quarters)
    @quarters = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_quarter, end_date: d.end_of_quarter } }.uniq
    @quarters
  end
end
