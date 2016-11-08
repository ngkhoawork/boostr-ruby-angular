class Api::KpisDashboardController < ApplicationController
  respond_to :json

  def win_rate_by_seller
    win_rate_list = []
    sellers = company.users.by_user_type(SELLER)

    seller_deals = Deal.joins('LEFT JOIN deal_members on deals.id = deal_members.deal_id').where('deal_members.user_id in (?)', sellers.ids).distinct.active.includes(:stage, :deal_members)

    win_rate_list << time_period_names

    sellers.each do |seller|
      win_rates = []
      time_periods.each do |time_period|
        complete_deals = seller_deals.select do |deal|
          deal.deal_members.map(&:user_id).include?(seller.id) &&
          deal.closed_at &&
          deal.closed_at >= time_period.first &&
          deal.closed_at <= time_period.last &&
          deal.stage.probability == 100
        end.count

        incomplete_deals = seller_deals.select do |deal|
          deal.deal_members.map(&:user_id).include?(seller.id) &&
          deal.closed_at &&
          deal.closed_at >= time_period.first &&
          deal.closed_at <= time_period.last &&
          deal.stage.probability == 0 &&
          deal.stage.open == false
        end.count

        win_rate = 0.0

        win_rate = (complete_deals.to_f / (complete_deals.to_f + incomplete_deals.to_f) * 100).round(0) if (incomplete_deals + complete_deals) > 0
        win_rates << win_rate
      end

      win_rates << (win_rates.reduce(&:+) / win_rates.length).round(0)
      win_rates.unshift(seller.name)
      win_rates.unshift(sellers_team(seller))
      win_rate_list << win_rates
    end
    averages = []
    win_rate_list[1..-1].transpose[2..-1].each do |average|
      averages << (average.reduce(:+) / average.length).round(0)
    end
    averages.unshift('', '')
    win_rate_list << averages

    render json: { win_rates: win_rate_list }
  end

  private

  def start_date
    Date.parse(params[:start_date])
  end

  def end_date
    Date.parse(params[:end_date])
  end

  def time_periods
    time_periods = TimePeriods.new
    case params[:time_period]
    when 'month'
      time_periods.months(start_date..end_date)
    when 'qtr'
      time_periods.quarters(start_date..end_date)
    end
  end

  def time_period_names
    names = %w[Team, Seller]
    if params[:time_period] == 'qtr'
      time_periods.each_with_index do |time_period, index|
        names << "Quarter #{index + 1}"
      end
    else
      time_periods.each do |time_period|
        names << time_period.first.strftime("%B")
      end
    end

    names << 'Total'
  end

  def sellers_team(seller)
    if seller.leader?
      company.teams.find_by(leader: seller).name
    else
      seller.team.name if seller.team
    end
  end

  def company
    @company ||= current_user.company
  end
end
