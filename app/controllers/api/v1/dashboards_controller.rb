class Api::V1::DashboardsController < ApiController
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
    return @time_period if defined?(@time_period)

    @time_period = company.time_periods.now
  end

  def next_time_period
    start_date = (Time.now.utc + 3.months).beginning_of_quarter
    end_date = (Time.now.utc + 3.months).end_of_quarter.beginning_of_day
    start_date..end_date
  end

  def forecast
    return @forecast if defined?(@forecast)

    return nil unless time_period

    if current_user.user_type == EXEC && user_quota_for_period(time_period.start_date, time_period.end_date) == 0
      @forecast = Forecast.new(company, company_teams, time_period.start_date, time_period.end_date)
    elsif current_user.leader?
      @forecast = Forecast.new(company, current_user.teams, time_period.start_date, time_period.end_date)
    else
      @forecast = ForecastMember.new(current_user, time_period.start_date, time_period.end_date)
    end
  end

  def next_quarter_forecast
    return @next_quarter_forecast if defined?(@next_quarter_forecast)

    if current_user.user_type == EXEC && user_quota_for_period(next_time_period.first, next_time_period.last) == 0
      @next_quarter_forecast = Forecast.new(company, company_teams, next_time_period.first, next_time_period.last)
    elsif current_user.leader?
      @next_quarter_forecast = Forecast.new(company, current_user.teams, next_time_period.first, next_time_period.last)
    else
      @next_quarter_forecast = ForecastMember.new(current_user, next_time_period.first, next_time_period.last)
    end
  end

  def user_quota_for_period(start_date, end_date)
    current_user.total_gross_quotas(start_date, end_date)
  end

  def company_teams
    @teams = company.teams.roots(true)
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
