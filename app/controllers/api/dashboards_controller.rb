class Api::DashboardsController < ApplicationController
  respond_to :json

  def show
    render json: {
      forecast: DashboardForecastSerializer.new(forecast),
      next_quarter_forecast: DashboardForecastSerializer.new(next_quarter_forecast),
      deals: serialized_deals,
      current_user: current_user,
      revenue: dashboard_pacing_alert_service.display_revenue
    }
  end

  def typeahead
    render json: deal_search
  end

  protected

  def dashboard_pacing_alert_service
    DashboardPacingAlertService.new(current_user: current_user, params: params)
  end

  def time_period
    @_time_period ||= company.time_periods.current_quarter
  end

  def next_time_period
    company.time_periods.all_quarter.find_by(start_date: time_period.end_date.next)
  end

  def forecast
    return nil unless time_period

    @_forecast ||= forecast_for(time_period)
  end

  def next_quarter_forecast
    return nil unless time_period || next_time_period

    @_next_quarter_forecast ||= forecast_for(next_time_period)
  end

  def forecast_for(period)
    if current_user.user_type.eql?(EXEC) && user_quota_for_period(period.start_date, period.end_date) == 0
      Forecast.new(company, company_teams, period.start_date, period.end_date)
    elsif current_user.leader?
      Forecast.new(company, current_user.teams, period.start_date, period.end_date)
    else
      ForecastMember.new(current_user, period.start_date, period.end_date)
    end
  end

  def user_quota_for_period(start_date, end_date)
    current_user.quotas.for_time_period(start_date, end_date).sum(:value)
  end

  def company_teams
    @_teams = company.teams.roots(true)
  end

  def deals
    @_deals ||= current_user.deals.open.order('start_date')
  end

  def deal_search
    @_deal_search ||= current_user.deals.open.by_name(params[:query])
  end

  def company
    @_company ||= current_user.company
  end

  def serialized_deals
    ActiveModel::ArraySerializer.new(deals, each_serializer: DashboardDealSerializer)
  end
end
