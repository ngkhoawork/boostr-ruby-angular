class Api::KpisDashboardController < ApplicationController
  respond_to :json

  def index
    win_rate_list = []
    average_size_list = []

    if params[:team] && params[:team] != 'all'
      object = team_members
    else
      object = teams
    end

    object.each do |item|
      win_rates = []
      average_deal_sizes = []

      if item.is_a?(User)
        ids = [item.id]
      else
        ids = item.all_sellers.map(&:id)
      end
      time_periods.each do |time_period|
        complete_deals = complete_deals_list(ids, time_period)
        incomplete_deals = incomplete_deals_list(ids, time_period)

        win_rate = 0.0
        average_deal_size = 0

        win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0

        total_deal_size = complete_deals.map(&:budget).compact.reduce(:+)
        if total_deal_size && complete_deals.count > 0
          average_deal_size = ((total_deal_size / complete_deals.count) / 100).round(0)
        end

        total_deals = complete_deals.count + incomplete_deals.count
        win_rates << { win_rate: win_rate, total_deals: total_deals, won: complete_deals.count, lost: incomplete_deals.count }
        average_deal_sizes << { average_deal_size: average_deal_size, total_deals: total_deals }
      end

      win_rates << average_win_rate_by_item(item)
      win_rates.unshift(item.name)
      win_rate_list << win_rates

      average_deal_sizes << averaged_size_by_item(average_deal_sizes)
      average_deal_sizes.unshift(item.name)
      average_size_list << average_deal_sizes
    end

    render json: {
      time_periods: time_period_names,
      win_rates: win_rate_list,
      average_win_rates: average_win_rates(win_rate_list),
      average_deal_sizes: average_size_list,
      averaged_average_deal_sizes: averaged_average_deal_sizes(average_size_list)
    }
  end

  private

  def complete_deals_list(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (if params[:product_id] && params[:product_id] != 'all'
          deal.products.map(&:id).include?(params[:product_id].to_i)
       else
          true
       end) &&
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      deal.closed_at &&
      deal.closed_at >= time_period.first &&
      deal.closed_at <= time_period.last &&
      deal.stage.probability == 100
    end
  end

  def incomplete_deals_list(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (if params[:product_id] && params[:product_id] != 'all'
          deal.products.map(&:id).include?(params[:product_id])
       else
          true
       end) &&
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      deal.closed_at &&
      deal.closed_at >= time_period.first &&
      deal.closed_at <= time_period.last &&
      deal.stage.probability == 0 &&
      deal.stage.open == false
    end
  end

  def deals_by_time_period
    type_field_id = company.fields.find_by(subject_type: 'Deal', name: 'Deal Type').id if params[:type] && params[:type] != 'all'
    source_field_id = company.fields.find_by(subject_type: 'Deal', name: 'Deal Source').id if params[:source] && params[:source] != 'all'
    @deals ||= Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id').where('deal_members.user_id in (?)', team_members.map(&:id)).by_type(params[:type], type_field_id).by_source(params[:source], source_field_id).distinct.active.includes(:stage, :deal_members, :products)
  end

  def teams
    if params[:team] && params[:team] != 'all'
      @team ||= [company.teams.find(params[:team])]
    else
      @team ||= root_teams
    end
  end

  def team_members
    @team_members ||= teams.map(&:all_sellers).flatten
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
      ids = item.all_sellers.map(&:id)
    end
    complete_deals = complete_deals_list(ids, full_time_period)
    incomplete_deals = incomplete_deals_list(ids, full_time_period)

    win_rate = 0.0

    win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0
    win_rate
  end

  def averaged_size_by_item(average_deal_sizes)
    (average_deal_sizes.map{|a| a[:average_deal_size] }.reduce(:+) / average_deal_sizes.length).round(0)
  end

  def time_periods
    time_periods = TimePeriods.new
    if params[:time_period] == 'qtr'
      time_periods.quarters(start_date..end_date)
    else
      time_periods.months(start_date..end_date)
    end
  end

  def full_time_period
    time_periods.first.first..time_periods.last.last
  end

  def average_win_rates(win_rate_list)
    averages = []

    if params[:team] && params[:team] != 'all'
      ids = team_members.map(&:id)
      ids << teams[0].leader.id if teams[0].leader
      time_periods.each do |time_period|
        complete_deals = complete_deals_list(ids, time_period)
        incomplete_deals = incomplete_deals_list(ids, time_period)

        win_rate = 0.0
        win_rate = (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f) * 100).round(0) if (incomplete_deals.count + complete_deals.count) > 0
        averages << win_rate
      end
    else
      win_rate_list.transpose[1..-2].each do |average|
        averages << ((average.map{|w| w[:win_rate] }.reduce(:+)) / average.length).round(0)
      end if win_rate_list.length > 0
    end

    total_win_rate = win_rate_list.map(&:last).reduce(:+)
    if total_win_rate && win_rate_list.length > 0
      total_average = (total_win_rate / win_rate_list.length).round(0)
    else
      total_average = 0
    end
    averages << total_average
  end

  def averaged_average_deal_sizes(average_size_list)
    averages = []

    if params[:team] && params[:team] != 'all'
      ids = team_members.map(&:id)
      ids << teams[0].leader.id if teams[0].leader
      time_periods.each do |time_period|
        complete_deals = complete_deals_list(ids, time_period)
        incomplete_deals = incomplete_deals_list(ids, time_period)

        average_deal_size = 0
        total_deal_size = complete_deals.map(&:budget).compact.reduce(:+)
        if total_deal_size && complete_deals.count > 0
          average_deal_size = ((total_deal_size / complete_deals.count) / 100).round(0)
        end

        averages << average_deal_size
      end
    else
      average_size_list.transpose[1..-2].each do |average|
        averages << ((average.map{|w| w[:average_deal_size] }.reduce(:+)) / average.length).round(0)
      end if average_size_list.length > 0
    end


    total_average_size = average_size_list.map(&:last).reduce(:+)
    if total_average_size && average_size_list.length > 0
      total_average = (total_average_size / average_size_list.length).round(0)
    else
      total_average = 0
    end
    averages << total_average
  end

  def time_period_names
    names = []
    if params[:time_period] == 'qtr'
      time_periods.each_with_index do |time_period, index|
        names << "Q#{index + 1}-#{time_period.first.year}"
      end
    else
      time_periods.each do |time_period|
        names << time_period.first.strftime("%B")
      end
    end
    names
  end

  def company
    @company ||= current_user.company
  end
end
