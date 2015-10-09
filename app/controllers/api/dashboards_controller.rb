class Api::DashboardsController < ApplicationController
  respond_to :json

  def show
    render json: { forecast: forecast, deals: deals }
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
      @forecast = Forecast.new(company, current_user.teams, time_period)
    else
      @forecast = ForecastMember.new(current_user, time_period)
    end
  end

  def deals
    return @deals if defined?(@deals)

    @deals = current_user.deals.open
  end

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end

end
