class Api::DashboardsController < ApplicationController
  respond_to :json

  def show
    render json: dashboard_data
  end

  def typeahead
    render json: deal_search
  end

  def pacing_alerts
    render json: dashboard_pacing_alert_service.display_revenue
  end

  protected

  def dashboard_data
    {
      forecast: serialized_forecast(closest_quarter),
      next_quarter_forecast: serialized_forecast(next_time_period),
      this_year_forecast: serialized_forecast(this_year_time_period),
      deals: serialized_deals,
      current_user: current_user
    }
  end

  def dashboard_pacing_alert_service
    DashboardPacingAlertService.new(current_user: current_user, params: params)
  end

  def closest_quarter
    @_closest_quarter ||= company.time_periods.all_quarter.closest.first
  end

  def next_time_period
    return nil unless closest_quarter

    company.time_periods.all_quarter.find_by(start_date: closest_quarter.end_date.next)
  end

  def this_year_time_period
    company.time_periods.years_only.find_by(start_date: Date.today.beginning_of_year)
  end

  def user_quota_for_period(start_date, end_date)
    current_user.total_gross_quotas(start_date, end_date)
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

  def serialized_forecast(time_period)
    return nil unless time_period.present?

    DashboardForecastSerializer.new forecast_for(time_period)
  end

  def forecast_for(period)
    if current_user.user_type.eql?(EXEC) && user_quota_for_period(period.start_date, period.end_date) == 0
      NewForecast.new(company, company_teams, period, nil)
    elsif current_user.leader?
      NewForecastTeam.new(current_user.teams.first, period, nil)
    else
      NewForecastMember.new(current_user, period, nil)
    end
  end
end
