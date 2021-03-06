class PacingDashboard::BaseService
  FIRST_QUARTER_NUMBER = 1
  LAST_QUARTER_NUMBER = 4

  def initialize(company, params)
    @company = company
    @params = params
    @time_period_id = params[:time_period_id]
    @product_id = params[:product_id]
    @team_id = params[:team_id]
    @seller_id = params[:seller_id]
    @deals = deals
  end

  private

  attr_reader :company, :deals, :params, :time_period_id, :product_id, :team_id, :seller_id

  def deals
    company.deals
           .by_product_id(product_id)
           .by_team_id(team_id)
           .by_seller_id(seller_id)
  end

  def current_quarter
    @_current_quarter ||= if time_period_id.present?
                            company.time_periods.find(time_period_id)
                          else
                            company.time_periods.current_quarter
                          end
  end

  def previous_quarter
    return nil if time_period_week_for_previous_quarter.blank?

    @_previous_quarter ||= company.time_periods.all_quarter.find_by(
      start_date: time_period_week_for_previous_quarter.period_start,
      end_date: time_period_week_for_previous_quarter.period_end
    )
  end

  def previous_year_quarter
    return nil if time_period_week_for_previous_year_quarter.blank?

    @_previous_year_quarter ||= company.time_periods.all_quarter.find_by(
      start_date: time_period_week_for_previous_year_quarter.period_start,
      end_date: time_period_week_for_previous_year_quarter.period_end
    )
  end

  def current_quarter_number
    @_current_quarter_number ||= /\d/.match(weeks_for_current_quarter.first.period_name)[0].to_i
  end

  def current_quarter_year
    @_current_quarter_year ||= /\d{4}/.match(weeks_for_current_quarter.first.period_name)[0].to_i
  end

  def previous_quarter_number
    current_quarter_number.eql?(FIRST_QUARTER_NUMBER) ? LAST_QUARTER_NUMBER : current_quarter_number - 1
  end

  def previous_quarter_year
    current_quarter_number.eql?(FIRST_QUARTER_NUMBER) ? current_quarter_year - 1 : current_quarter_year
  end

  def previous_year_quarter_year
    current_quarter_year - 1
  end

  def time_period_week_for_previous_quarter
    @_time_period_week_for_previous_quarter ||=
      TimePeriodWeek.find_by(period_name: "Q#{previous_quarter_number}-#{previous_quarter_year}")
  end

  def time_period_week_for_previous_year_quarter
    @_time_period_week_for_previous_year_quarter ||=
      TimePeriodWeek.find_by(period_name: "Q#{current_quarter_number}-#{previous_year_quarter_year}")
  end

  def all_time_period_weeks_for_current_quarter
    @_all_time_period_weeks_for_current_quarter ||=
      TimePeriodWeek.by_period_start_and_end(current_quarter.start_date, current_quarter.end_date)
  end

  def weeks_for_current_quarter
    @_weeks_for_current_quarter ||=
      use_all_time_period_weeks? ? all_time_period_weeks_for_current_quarter : all_time_period_weeks_for_current_quarter.with_positive_weeks
  end

  def all_time_period_weeks_for_previous_quarter
    @_all_time_period_weeks_for_previous_quarter ||=
      TimePeriodWeek.by_period_start_and_end(previous_quarter.start_date, previous_quarter.end_date)
  end

  def weeks_for_previous_quarter
    @_weeks_for_previous_quarter ||=
      use_all_time_period_weeks? ? all_time_period_weeks_for_previous_quarter : all_time_period_weeks_for_previous_quarter.with_positive_weeks
  end

  def all_time_period_weeks_for_previous_year_quarter
    @_all_time_period_weeks_for_previous_year_quarter ||=
      TimePeriodWeek.by_period_start_and_end(previous_year_quarter.start_date, previous_year_quarter.end_date)
  end

  def weeks_for_previous_year_quarter
    @_weeks_for_previous_year_quarter ||=
      use_all_time_period_weeks? ? all_time_period_weeks_for_previous_year_quarter : all_time_period_weeks_for_previous_year_quarter.with_positive_weeks
  end

  def empty_value
    @_empty_value ||= 0
  end

  def empty_weeks_data
    use_all_time_period_weeks? ? Array.new(21, empty_value) : Array.new(13, empty_value)
  end

  def use_all_time_period_weeks?
    false
  end
end
