class Api::InactivesController < ApplicationController
  respond_to :json

  def inactives
    result = []

    @inactives = Client.where(id: advertisers_with_revenue(in_range: previous_quarters) - advertisers_with_revenue(in_range: [current_quarter]))
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
      .includes(:users, :advertiser_deals)

    @inactives.each do |advertiser|
      last_activity = advertiser.activities.order(happened_at: :desc).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      result << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_quarterly_spend: average_quarterly_spend(advertiser, in_range: previous_quarters),
        open_pipeline: open_pipeline(advertiser),
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    render json: result.sort_by{ |el| el[:average_quarterly_spend] * -1 }
  end

  def seasonal_inactives
    result = []

    @inactives = Client.where(id: advertisers_with_revenue(in_range: comparison_window[:first]) - advertisers_with_revenue(in_range: comparison_window[:second]))
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
      .includes(:users, :advertiser_deals)

    @inactives.each do |advertiser|
      last_activity = advertiser.activities.order(happened_at: :desc).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      result << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_quarterly_spend: average_quarterly_spend(advertiser, in_range: comparison_window[:first]),
        open_pipeline: open_pipeline(advertiser),
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    render json: result.sort_by{ |el| el[:average_quarterly_spend] * -1 }
  end

  def soon_to_be_inactive
    result = []

    @inactives = Client.where(id: advertisers_with_decreased_revenue)
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
      .includes(:users, :advertiser_deals)

    @inactives.each do |advertiser|
      last_activity = advertiser.activities.order(happened_at: :desc).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      result << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_quarterly_spend: average_quarterly_spend(advertiser, in_range: previous_quarters(lookback: 1)),
        open_pipeline: open_pipeline(advertiser),
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    render json: result.sort_by{ |el| el[:average_quarterly_spend] * -1 }
  end

  private

  def advertisers_with_revenue(in_range:)
    time_dimensions = TimeDimension.where(start_date: in_range.map(&:first), end_date: in_range.map(&:last))
    advertiser_ids = []

    time_dimensions.each_with_index do |time_dimension, index|
      accounts_with_revenues = AccountRevenueFact
        .joins("INNER JOIN account_dimensions on account_revenue_facts.account_dimension_id = account_dimensions.id")
        .where('account_dimensions.account_type = ?', Client::ADVERTISER)
        .where('revenue_amount > 0')
        .where(time_dimension_id: time_dimension.id)
        .select(:account_dimension_id)
        .map(&:account_dimension_id)

      if index == 0
        advertiser_ids.concat accounts_with_revenues
      else
        advertiser_ids.concat(accounts_with_revenues & advertiser_ids)
      end
    end

    advertiser_ids.uniq
  end

  def advertisers_with_decreased_revenue
    current_quarter_dimension = TimeDimension.find_by(start_date: current_quarter.first, end_date: current_quarter.last)
    previous_quarter_dimension = TimeDimension.find_by(start_date: previous_quarters(lookback: 1).map(&:first), end_date: previous_quarters(lookback: 1).map(&:last))
    advertiser_ids = advertisers_with_revenue(in_range: previous_quarters(lookback: 1) + [current_quarter])
    advertiser_ids.select do |advertiser_id|
      previous_quarter_revenue = AccountRevenueFact.find_by(
        account_dimension_id: advertiser_id,
        time_dimension_id: previous_quarter_dimension.id
      ).revenue_amount

      AccountRevenueFact.where(account_dimension_id: advertiser_id)
      .where(time_dimension_id: current_quarter_dimension.id)
      .where('revenue_amount <= ?', previous_quarter_revenue * (revenue_decrease / 100.0))
      .exists?
    end
  end

  def average_quarterly_spend(advertiser, in_range:)
    time_dimensions = TimeDimension.where(start_date: in_range.map(&:first), end_date: in_range.map(&:last))
    @total_revenues ||= AccountRevenueFact.where(account_dimension_id: @inactives.ids)
    .where(time_dimension_id: time_dimensions.ids)
    .group(:account_dimension_id)
    .select('account_dimension_id, sum(revenue_amount) as total_revenue')
    .collect{|el| {account_dimension_id: el.account_dimension_id, total_revenue: el.total_revenue} }

    total_revenue = @total_revenues.find{|el| el[:account_dimension_id] == advertiser.id}
    (total_revenue[:total_revenue] / in_range.length).round(0)
  end

  def open_pipeline(advertiser)
    pipeline = advertiser.advertiser_deals.map(&:budget).compact.reduce(:+)
    if pipeline == nil
      0
    else
      (pipeline / 100).round(0)
    end
  end

  def company
    @company ||= current_user.company
  end

  def current_quarter
    first = Date.today.beginning_of_quarter
    last = Date.today.end_of_quarter
    first..last
  end

  def current_month
    first = Date.today.beginning_of_month
    last = Date.today.end_of_month
    first..last
  end

  def comparison_window
    if params[:time_period_type] && params[:time_period_number]
      if params[:time_period_type] == 'quarter'
        first = previous_quarters(lookback: 8)[params[:time_period_number].to_i - 1]
        second = (previous_quarters(lookback: 4) << current_quarter)[params[:time_period_number].to_i - 1]
      elsif params[:time_period_type] == 'month'
        first = previous_months(lookback: 24)[params[:time_period_number].to_i - 1]
        second = (previous_months(lookback: 12) << current_month)[params[:time_period_number].to_i - 1]
      end
    else
      first = previous_quarters(lookback: 4).first
      second = current_quarter
    end

    {
      first: [first],
      second: [second]
    }
  end

  def previous_quarters(lookback: qtr_offset)
    quarters = []
    lookback.times do
      first = Date.today.beginning_of_quarter << ((lookback - quarters.length) * 3)
      last = Date.today.end_of_quarter << ((lookback - quarters.length) * 3)
      quarters << (first..last)
    end
    quarters
  end

  def previous_months(lookback: month_offset)
    months = []
    lookback.times do
      first = Date.today.beginning_of_month << lookback - months.length
      last = Date.today.end_of_month << lookback - months.length
      months << (first..last)
    end
    months
  end

  def qtr_offset
    (params[:qtrs] || 2).to_i
  end

  def revenue_decrease
    params[:revenue_decrease] || 75
  end
end
