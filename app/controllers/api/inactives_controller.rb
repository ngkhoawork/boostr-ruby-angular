class Api::InactivesController < ApplicationController
  respond_to :json

  def index
    render json: {
      inactives: inactives
    }
  end

  private

  def inactives
    inactives = []
    inactive_advertisers.each do |advertiser|
      last_activity = advertiser.activities.sort_by(&:happened_at).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      inactives << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_quarterly_spend: average_quarterly_spend(advertiser),
        open_pipeline: open_pipeline(advertiser),
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    inactives.sort_by{|el| el[:average_quarterly_spend] * -1 }
  end

  def inactive_advertisers
    @inactives = Client.where(id: advertisers_with_consecutive_revenues_in_past - advertisers_with_current_revenue)
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
      .includes(:activities, :users, :advertiser_deals)
  end

  def advertisers_with_current_revenue
    time_dimension = TimeDimension.find_by(start_date: current_quarter.first, end_date: current_quarter.last)
    AccountRevenueFact
      .joins("INNER JOIN account_dimensions on account_revenue_facts.account_dimension_id = account_dimensions.id")
      .where('account_dimensions.account_type = ?', Client::ADVERTISER)
      .where('revenue_amount > 0')
      .where(time_dimension_id: time_dimension.id)
      .select(:account_dimension_id)
      .map(&:account_dimension_id)
  end

  def advertisers_with_consecutive_revenues_in_past
    time_dimensions = TimeDimension.where(start_date: previous_quarters.map(&:first), end_date: previous_quarters.map(&:last))
    advertisers = []

    time_dimensions.each_with_index do |time_dimension, index|
      accounts_with_revenues = AccountRevenueFact
        .joins("INNER JOIN account_dimensions on account_revenue_facts.account_dimension_id = account_dimensions.id")
        .where('account_dimensions.account_type = ?', Client::ADVERTISER)
        .where('revenue_amount > 0')
        .where(time_dimension_id: time_dimension.id)
        .select(:account_dimension_id)
        .map(&:account_dimension_id)

      if index == 0
        advertisers.concat accounts_with_revenues
      else
        advertisers.concat(accounts_with_revenues & advertisers)
      end
    end

    advertisers
  end

  def average_quarterly_spend(advertiser)
    time_dimensions = TimeDimension.where(start_date: previous_quarters.map(&:first), end_date: previous_quarters.map(&:last))
    @total_revenues ||= AccountRevenueFact.where(account_dimension_id: @inactives.ids)
    .where(time_dimension_id: time_dimensions.ids)
    .group(:account_dimension_id)
    .select('account_dimension_id, sum(revenue_amount) as total_revenue')
    .collect{|el| {account_dimension_id: el.account_dimension_id, total_revenue: el.total_revenue} }

    total_revenue = @total_revenues.find{|el| el[:account_dimension_id] == advertiser.id}
    (total_revenue[:total_revenue] / qtr_offset).round(0)
  end

  def open_pipeline(advertiser)
    pipeline = advertiser.advertiser_deals.map(&:budget).compact.reduce(:+)
    if pipeline == nil
      0
    else
      (pipeline / 100).round(0)
    end
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def company
    @company ||= current_user.company
  end

  def full_time_period
    first = Date.today.beginning_of_quarter << (qtr_offset * 3)
    last = Date.today
    first..last
  end

  def current_quarter
    first = Date.today.beginning_of_quarter
    last = Date.today.end_of_quarter
    first..last
  end

  def lookback_window
    first = Date.today.beginning_of_quarter << (qtr_offset * 3)
    last = Date.today.end_of_quarter << (1 * 3)
    first..last
  end

  def previous_quarters
    quarters = []
    qtr_offset.times do
      first = Date.today.beginning_of_quarter << ((qtr_offset - quarters.length) * 3)
      last = Date.today.end_of_quarter << ((qtr_offset - quarters.length) * 3)
      quarters << (first..last)
    end
    quarters
  end

  def qtr_offset
    (params[:qtrs] || 2).to_i
  end
end
