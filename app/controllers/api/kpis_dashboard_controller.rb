class Api::KpisDashboardController < ApplicationController
  respond_to :json

  def index
    win_rate_list = []
    average_size_list = []
    cycle_time_list = []
    @time_period_builder ||= TimePeriods.new(start_date..end_date)

    if params[:seller] && params[:seller] !='all'
      object = team_members
    elsif params[:team] && params[:team] != 'all'
      if team.children.any?
        object = team.children
        object += team.members.by_user_type([SELLER, SALES_MANAGER])
        object << team.leader if !team.leader.nil?
      else
        object = team_members
      end
    else
      object = teams
    end

    object.each do |item|
      win_rates = []
      average_deal_sizes = []
      cycle_times = []

      if item.is_a?(User)
        ids = [item.id]
      else
        ids = item.all_sales_reps.map(&:id)
      end
      time_periods.each do |time_period|
        complete_deals = complete_deals_list(ids, time_period)
        incomplete_deals = incomplete_deals_list(ids, time_period)

        win_rate = 0.0
        average_deal_size = 0
        cycle_time = 0.0

        win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0

        if product_ids.present?
          total_deal_size = complete_deals.map{|d| d.deal_products.where(product_id: product_ids)}
                              .flatten.map(&:budget).compact.reduce(:+)
        else
          total_deal_size = complete_deals.map(&:budget).compact.reduce(:+)
        end
        if total_deal_size && complete_deals.count > 0
          average_deal_size = ((total_deal_size / complete_deals.count) / 1000.0).round(0).to_i
        end
        cycle_time_arr = complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s) - Date.parse(deal.created_at.utc.to_s)}
        cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1).round(0) if cycle_time_arr.count > 0

        total_deals = complete_deals.count + incomplete_deals.count

        win_rates << { win_rate: win_rate, total_deals: total_deals, won: complete_deals.count, lost: incomplete_deals.count }
        average_deal_sizes << { average_deal_size: average_deal_size, total_deals: total_deals, won: complete_deals.count }
        cycle_times << { cycle_time: cycle_time, total_deals: total_deals, won: complete_deals.count }
      end

      win_rates << average_win_rate_by_item(item)
      win_rates.unshift(item.name)
      win_rate_list << win_rates

      average_deal_sizes << averaged_size_by_item(item)
      average_deal_sizes.unshift(item.name)
      average_size_list << average_deal_sizes

      cycle_times << average_cycle_time_by_item(item)
      cycle_times.unshift(item.name)
      cycle_time_list << cycle_times
    end

    render json: {
      time_periods: @time_period_builder.time_period_names(params[:time_period]),
      win_rates: win_rate_list << average_win_rates,
      average_deal_sizes: average_size_list << averaged_average_deal_sizes,
      cycle_times: cycle_time_list << average_cycle_time
    }
  end

  private

  def product_ids
    @_product_ids ||= if params[:product_id] && params[:product_id] != 'all'
      Product.include_children(company.products.where(id: params[:product_id])).collect(&:id)
    end
  end

  def complete_deals_list(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (if product_ids.present?
          (product_ids & deal.products.map(&:id)).present?
        else
          true
        end) &&
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      (params[:type] && params[:type] != 'all' ? deal.values.map(&:option_id).include?(params[:type].to_i) : true) &&
      (params[:source] && params[:source] != 'all' ? deal.values.map(&:option_id).include?(params[:source].to_i) : true) &&
      deal.send(date_criteria_filter.to_sym) >= time_period.first &&
      deal.send(date_criteria_filter.to_sym) <= time_period.last &&
      deal.stage.probability == 100
    end
  end

  def incomplete_deals_list(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (if product_ids.present?
          (product_ids & deal.products.map(&:id)).present?
        else
          true
        end) &&
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      (params[:type] && params[:type] != 'all' ? deal.values.map(&:option_id).include?(params[:type].to_i) : true) &&
      (params[:source] && params[:source] != 'all' ? deal.values.map(&:option_id).include?(params[:source].to_i) : true) &&
      deal.send(date_criteria_filter.to_sym) >= time_period.first &&
      deal.send(date_criteria_filter.to_sym) <= time_period.last &&
      deal.stage.probability == 0 &&
      deal.stage.open == false
    end
  end

  def deals_by_time_period
    value_params = [params[:type], params[:source]].reject{|el| el.nil? || el == 'all'}
    @deals ||= Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id')
                   .where('deal_members.user_id in (?)', team_members.map(&:id))
                   .where("deals.#{date_criteria_filter} >= ? and deals.#{date_criteria_filter} <= ?", start_date, end_date)
                   .where('stage_id in (?)', closed_stages)
                   .by_values(value_params)
                   .distinct
                   .active
                   .includes(:stage, :products, :deal_members, 'values')
  end

  def team
    @team = company.teams.find(params[:team])
  end

  def teams
    if params[:team] && params[:team] != 'all'
      @teams ||= [company.teams.find(params[:team])]
    else
      @teams ||= root_teams
    end
  end

  def team_members
    if params[:seller] && params[:seller] !='all'
      @team_members ||= company.users.where(id: params[:seller])
    else
      @team_members ||= teams.map(&:all_sales_reps).flatten.sort_by(&:first_name)
    end
  end

  def root_teams
    company.teams.roots(true)
  end

  def start_date
    if params[:start_date]
      Date.parse(params[:start_date])
    else
      (Date.current - 6.months).beginning_of_month
    end
  end

  def end_date
    if params[:end_date]
      Date.parse(params[:end_date])
    else
      (Date.current - 1.months).end_of_month
    end
  end

  def average_win_rate_by_item(item)
    if item.is_a?(User)
      ids = [item.id]
    else
      ids = item.all_sales_reps.map(&:id)
    end
    complete_deals = complete_deals_list(ids, full_time_period)
    incomplete_deals = incomplete_deals_list(ids, full_time_period)

    win_rate = 0.0

    win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0
    win_rate
  end

  def averaged_size_by_item(item)
    if item.is_a?(User)
      ids = [item.id]
    else
      ids = item.all_sales_reps.map(&:id)
    end
    complete_deals = complete_deals_list(ids, full_time_period)
    incomplete_deals = incomplete_deals_list(ids, full_time_period)

    average_deal_size = 0
    if product_ids.present?
      total_deal_size = complete_deals.map{|d| d.deal_products.where(product_id: product_ids)}.flatten.map(&:budget).compact.reduce(:+)
    else
      total_deal_size = complete_deals.map(&:budget).compact.reduce(:+)
    end

    if total_deal_size && complete_deals.count > 0
      average_deal_size = ((total_deal_size / complete_deals.count) / 1000.0).round(0).to_i
    end
    average_deal_size
  end

  def average_cycle_time_by_item(item)
    if item.is_a?(User)
      ids = [item.id]
    else
      ids = item.all_sales_reps.map(&:id)
    end

    complete_deals = complete_deals_list(ids, full_time_period)
    incomplete_deals = incomplete_deals_list(ids, full_time_period)

    cycle_time = 0.0
    cycle_time_arr = complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s) - Date.parse(deal.created_at.utc.to_s)}
    cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1).round(0) if cycle_time_arr.count > 0
    cycle_time
  end

  def time_periods
    if params[:time_period] == 'qtr'
      @time_periods ||= @time_period_builder.quarters
    else
      @time_periods ||= @time_period_builder.months
    end
  end

  def full_time_period
    time_periods.first.first..time_periods.last.last
  end

  def average_win_rates
    averages = ['Average']
    ids = team_members.map(&:id)

    time_periods.each do |time_period|
      complete_deals = complete_deals_list(ids, time_period)
      incomplete_deals = incomplete_deals_list(ids, time_period)
      total_deals = complete_deals.count + incomplete_deals.count

      win_rate = 0.0
      win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0
      averages << {win_rate: win_rate, total_deals: total_deals, won: complete_deals.count, lost: incomplete_deals.count }
    end

    all_complete_deals = complete_deals_list(ids, full_time_period)
    all_incomplete_deals = incomplete_deals_list(ids, full_time_period)

    total_grand_win_rate = 0.0

    total_grand_win_rate = (all_complete_deals.count.to_f / (all_complete_deals.count.to_f + all_incomplete_deals.count.to_f) * 100).round(0) if (all_incomplete_deals.count + all_complete_deals.count) > 0

    averages << total_grand_win_rate
  end

  def averaged_average_deal_sizes
    averages = ['Average']
    ids = team_members.map(&:id)

    time_periods.each do |time_period|
      complete_deals = complete_deals_list(ids, time_period)
      incomplete_deals = incomplete_deals_list(ids, time_period)
      total_deals = complete_deals.count + incomplete_deals.count

      average_deal_size = 0

      if product_ids.present?
        total_deal_size = complete_deals.map{|d| d.deal_products.where(product_id: product_ids)}.flatten.map(&:budget).compact.reduce(:+)
      else
        total_deal_size = complete_deals.map(&:budget).compact.reduce(:+)
      end
      if total_deal_size && complete_deals.count > 0
        average_deal_size = ((total_deal_size / complete_deals.count) / 1000.0).round(0).to_i
      end

      averages << { average_deal_size: average_deal_size, total_deals: total_deals, won: complete_deals.count }
    end

    all_complete_deals = complete_deals_list(ids, full_time_period)

    total_grand_average_size = 0

    if product_ids.present?
      total_deal_size = all_complete_deals.map{|d| d.deal_products.where(product_id: product_ids)}.flatten.map(&:budget).compact.reduce(:+)
    else
      total_deal_size = all_complete_deals.map(&:budget).compact.reduce(:+)
    end
    if total_deal_size && all_complete_deals.count > 0
      total_grand_average_size = ((total_deal_size / all_complete_deals.count) / 1000.0).round(0).to_i
    end

    averages << total_grand_average_size
  end

  def average_cycle_time
    averages = ['Average']
    ids = team_members.map(&:id)

    time_periods.each do |time_period|
      complete_deals = complete_deals_list(ids, time_period)
      incomplete_deals = incomplete_deals_list(ids, time_period)
      total_deals = complete_deals.count + incomplete_deals.count
      cycle_time = 0.0

      cycle_time_arr = complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s) - Date.parse(deal.created_at.utc.to_s)}
      cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1).round(0) if cycle_time_arr.count > 0

      averages << { cycle_time: cycle_time, total_deals: total_deals, won: complete_deals.count }
    end

    all_complete_deals = complete_deals_list(ids, full_time_period)
    total_grand_cycle_time = 0.0

    cycle_time_arr = all_complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s) - Date.parse(deal.created_at.utc.to_s)}
    total_grand_cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1).round(0) if cycle_time_arr.count > 0

    averages << total_grand_cycle_time
  end

  def company
    @company ||= current_user.company
  end

  def date_criteria_filter
    if params[:date_criteria] == 'created_date'
      'created_at'
    else
      'closed_at'
    end
  end

  def closed_stages
    Stage.where(company_id: company.id, active: true, open: false).where('probability in (?)', [0, 100]).ids
  end
end
