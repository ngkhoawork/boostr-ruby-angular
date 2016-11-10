class Api::KpisDashboardController < ApplicationController
  respond_to :json

  def index
    win_rate_list = []

    if params[:team]
      object = team_members
    else
      object = teams
    end

    object.each do |item|
      win_rates = []

      if item.is_a?(User)
        ids = [item.id]
      else
        ids = item.all_sellers.map(&:id)
      end
      time_periods.each do |time_period|
        complete_deals = complete_deals_count(ids, time_period)
        incomplete_deals = incomplete_deals_count(ids, time_period)

        win_rate = 0.0

        win_rate = (complete_deals.to_f / (complete_deals.to_f + incomplete_deals.to_f) * 100).round(0) if (incomplete_deals + complete_deals) > 0
        total_deals = complete_deals + incomplete_deals
        win_rates << { win_rate: win_rate, total_deals: total_deals }
      end

      win_rates << average_win_rate_by_item(win_rates)
      win_rates.unshift(item.name)
      win_rate_list << win_rates
    end

    render json: {
      win_rates: win_rate_list,
      time_periods: time_period_names,
      average_win_rates: average_win_rates(win_rate_list)
    }
  end

  private

  def complete_deals_count(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      deal.closed_at &&
      deal.closed_at >= time_period.first &&
      deal.closed_at <= time_period.last &&
      deal.stage.probability == 100
    end.count    
  end

  def incomplete_deals_count(deal_member_ids, time_period)
    deals_by_time_period.select do |deal|
      (deal.deal_members.map(&:user_id) & deal_member_ids).length > 0 &&
      deal.closed_at &&
      deal.closed_at >= time_period.first &&
      deal.closed_at <= time_period.last &&
      deal.stage.probability == 0 &&
      deal.stage.open == false
    end.count    
  end

  def deals_by_time_period
    @deals ||= Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id').where('deal_members.user_id in (?)', team_members.map(&:id)).distinct.active.includes(:stage, :deal_members)
  end

  def teams
    if params[:team]
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

  def average_win_rate_by_item(win_rates)
    (win_rates.map{|w| w[:win_rate]}.reduce(:+) / win_rates.length).round(0)
  end

  def time_periods
    time_periods = TimePeriods.new
    if params[:time_period] == 'qtr'
      time_periods.quarters(start_date..end_date)
    else
      time_periods.months(start_date..end_date)
    end
  end

  def average_win_rates(win_rate_list)
    averages = []

    if params[:team]
      ids = team_members.map(&:id) << teams[0].leader.id
      time_periods.each do |time_period|
        complete_deals = complete_deals_count(ids, time_period)
        incomplete_deals = incomplete_deals_count(ids, time_period)

        win_rate = 0.0
        win_rate = (complete_deals.to_f / (complete_deals.to_f + incomplete_deals.to_f) * 100).round(0) if (incomplete_deals + complete_deals) > 0
        averages << win_rate
      end
      averages
    else
      win_rate_list.transpose[1..-2].each do |average|
        averages << ((average.map{|w| w[:win_rate] }.reduce(:+)) / average.length).round(0)
      end if win_rate_list.length > 0
      averages
    end
  end

  def time_period_names
    names = []
    if params[:time_period] == 'qtr'
      time_periods.each_with_index do |time_period, index|
        names << "Quarter #{index + 1}"
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
