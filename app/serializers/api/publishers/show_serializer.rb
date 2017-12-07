class Api::Publishers::ShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :comscore, :website, :estimated_monthly_impressions, :actual_monthly_impressions, :client_id,
             :created_at, :publisher_stage_id, :type_id, :fill_rate, :revenue_lifetime, :revenue_ytd

  def fill_rate
    daily_actuals_for_current_month.sum(:fill_rate) / daily_actuals_for_current_month.count rescue 0
  end

  def revenue_lifetime
    daily_actuals_for_current_month.sum(:total_revenue)
  end

  def revenue_ytd
    daily_actuals_for_current_year.sum(:total_revenue)
  end

  private

  def daily_actuals_for_current_month
    @_daily_actuals_for_current_month ||=
      object.daily_actuals.by_date(current_date.beginning_of_month, current_date.end_of_month)
  end

  def daily_actuals_for_current_year
    @_daily_actuals_for_current_year ||= object.daily_actuals.by_date(current_date.beginning_of_year, current_date)
  end

  def current_date
    @_current_month ||= Date.today
  end
end
