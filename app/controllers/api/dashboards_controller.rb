class Api::DashboardsController < ApplicationController
  respond_to :json

  def show
    render json: { forecast: DashboardForecastSerializer.new(forecast), deals: serialized_deals, current_user: current_user }
  end

  def typeahead
    render json: deal_search
  end

  protected

  def time_period
    return @time_period if defined?(@time_period)

    @time_period = company.time_periods.now
  end

  def forecast
    return @forecast if defined?(@forecast)

    return nil unless time_period

    if current_user.leader?
      @forecast = Forecast.new(company, current_user.teams, time_period.start_date, time_period.end_date)
    else
      @forecast = ForecastMember.new(current_user, time_period.start_date, time_period.end_date)
    end
  end

  def deals
    return @deals if defined?(@deals)

    @deals = current_user.deals.open.order("start_date asc")
  end

  def deal_search
    return @deal_search if defined?(@deal_search)

    @deal_search = current_user.deals.open.where('name ilike ?', "%#{params[:query]}%")
  end

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end

  def serialized_deals
    ActiveModel::ArraySerializer.new(deals, each_serializer: DashboardDealSerializer)
  end

end
