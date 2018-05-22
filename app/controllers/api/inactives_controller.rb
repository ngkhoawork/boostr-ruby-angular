class Api::InactivesController < ApplicationController
  respond_to :json

  def inactives
    @inactives = inactives_data(inactives_ids)

    render json: @inactives,
              each_serializer: Inactives::InactivesSerializer,
              spend_range_length: previous_quarters.length,
              total_revenues: total_revenues(in_range: previous_quarters),
              inactives_ids: @inactives.ids
  end

  def seasonal_inactives
    @inactives = inactives_data(seasonal_inactives_ids)

    render json: {
        seasonal_inactives: ActiveModel::ArraySerializer.new(
          @inactives,
          each_serializer: Inactives::InactivesSerializer,
          spend_range_length: comparison_window[:first].length,
          total_revenues: total_revenues(in_range: comparison_window[:first]),
          inactives_ids: @inactives.ids
        ),
        season_names: season_names
      }
  end

  def soon_to_be_inactive
    @inactives = inactives_data(advertisers_with_decreased_revenue)

    render json: @inactives,
              each_serializer: Inactives::InactivesSerializer,
              spend_range_length: previous_quarters(lookback: 1).length,
              total_revenues: total_revenues(in_range: previous_quarters(lookback: 1)),
              inactives_ids: @inactives.ids
  end

  private

  def inactives_data(ids)
    options = { 
      ids: ids, 
      category_id: params[:category_id], 
      subcategory_id: params[:subcategory_id],
      team_id: params[:team_id],
      seller_id: params[:seller_id]
    }
    InactiveClientsQuery.new(options).perform
  end

  def inactives_ids
    advertisers_with_revenue(in_range: previous_quarters) - advertisers_with_revenue(in_range: [current_quarter])
  end

  def seasonal_inactives_ids
    advertisers_with_revenue(in_range: comparison_window[:first]) - advertisers_with_revenue(in_range: comparison_window[:second])
  end

  def total_revenues(in_range:)
    time_dimensions = TimeDimension.by_dates(in_range.map(&:first), in_range.map(&:last))
    @total_revenues ||= AccountRevenueFact.where(account_dimension_id: @inactives.ids)
    .where(time_dimension_id: time_dimensions.ids)
    .group(:account_dimension_id)
    .select('account_dimension_id, sum(revenue_amount) as total_revenue')
    .collect{|el| {account_dimension_id: el.account_dimension_id, total_revenue: el.total_revenue} }
  end

  def advertisers_with_revenue(in_range:)
    time_dimensions = TimeDimension.by_dates(in_range.map(&:first), in_range.map(&:last)).yearly
    advertiser_ids = []

    time_dimensions.each_with_index do |time_dimension, index|
      accounts_with_revenues = AccountRevenueFact
        .joins("INNER JOIN account_dimensions on account_revenue_facts.account_dimension_id = account_dimensions.id")
        .where('account_dimensions.account_type = ?', Client::ADVERTISER)
        .where('revenue_amount > 0')
        .where(time_dimension_id: time_dimension.id)
        .where(company_id: company.id)
        .select(:account_dimension_id)
        .map(&:account_dimension_id)

      if index == 0
        advertiser_ids.concat accounts_with_revenues
      else
        advertiser_ids = accounts_with_revenues & advertiser_ids
      end
    end

    advertiser_ids.uniq
  end

  def advertisers_with_decreased_revenue
    current_quarter_dimension = TimeDimension.by_dates(current_quarter.first, current_quarter.last).limit(1)
    previous_quarter_dimension = TimeDimension.by_dates(
      previous_quarters(lookback: 1).map(&:first),
      previous_quarters(lookback: 1).map(&:last)
    ).limit(1)

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
      last_year_start = Date.today.beginning_of_year << 12
      end_of_this_year = Date.today.end_of_year
      time_periods = TimePeriods.new(last_year_start..end_of_this_year)

      if params[:time_period_type] == 'quarter'
        current_time_period = time_periods.quarters[params[:time_period_number].to_i - 1]
      elsif params[:time_period_type] == 'month'
        current_time_period = time_periods.months[params[:time_period_number].to_i - 1]
      end
      period_in_previous_year = (current_time_period.first << 12)..(current_time_period.last << 12)
    else
      period_in_previous_year = previous_quarters(lookback: 4).first
      current_time_period = current_quarter
    end

    {
      first: [period_in_previous_year],
      second: [current_time_period]
    }
  end

  def season_names
    last_year_start = Date.today.beginning_of_year << 12
    end_of_this_year = Date.today.end_of_year
    time_periods = TimePeriods.new(last_year_start..end_of_this_year)
    time_periods.all_time_periods_with_names
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

  def qtr_offset
    (params[:qtrs] || 2).to_i
  end

  def revenue_decrease
    params[:revenue_decrease] || 75
  end
end
