class Api::KpisController < ApplicationController
  respond_to :json

  def index
    users = current_user.company.users
    users.each do |user|
      complete_deals = user.deals.closed.closed_in(90).at_percent(100)
      incomplete_deals = user.deals.closed.closed_in(90).at_percent(0)
      complete_deals_count = complete_deals.count
      incomplete_deals_count = incomplete_deals.count

      win_rate = 0.0
      average_deal_size = 0
      cycle_time = 0.0

      win_rate = complete_deals_count.to_f / (complete_deals_count + incomplete_deals_count) if (complete_deals_count + incomplete_deals_count) > 0

      average_deal_size = complete_deals.average(:budget) if complete_deals_count > 0

      cycle_time_arr = complete_deals.collect{|deal| Date.parse(DateTime.parse(deal.closed_at.to_s).utc.to_s)  - Date.parse(deal.created_at.utc.to_s)}
      cycle_time = (cycle_time_arr.sum.to_f / cycle_time_arr.count + 1) if cycle_time_arr.count > 0

      user.win_rate = win_rate.round(2) if win_rate > 0
      user.average_deal_size = (average_deal_size / 100.0).round(2) if average_deal_size.present? && average_deal_size > 0
      user.cycle_time = cycle_time.round(2) if cycle_time > 0
      user.save!
    end
    render nothing: true
  end
end
