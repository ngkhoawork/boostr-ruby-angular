class Api::DashboardsController < ApplicationController
  respond_to :json

  def show
    render json: { forecast: forecast }
  end

  protected

  def time_period
    return @time_period if defined?(@time_period)
    @time_period = current_user.company.time_periods.now
  end

  def forecast
    return @forecast if defined?(@forecast)

    return nil unless time_period

    if current_user.leader?
      @forecast = Forecast.new(current_user.teams, time_period)
    else
      @forecast = ForecastMember.new(current_user, time_period)
    end
  end
end