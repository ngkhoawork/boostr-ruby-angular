class PacingDashboardService
  FIRST_QUARTER_NUMBER = 1
  LAST_QUARTER_NUMBER = 4

  def initialize(company)
    @company = company
  end

  def perform
    {
        new_deals: {
            current_quarter: current_quarter_series,
            previous_quarter: previous_quarter_series,
            previous_year_quarter: previous_year_quarter_series
        },
        won_deals: {
            current_quarter: won_current_quarter_series,
            previous_quarter: won_previous_quarter_series,
            previous_year_quarter: won_previous_year_quarter_series
        }
    }
  end

  private

  attr_reader :company

  def deals_for_current_quarter
    @_deals_for_current_quarter ||=
        company.deals.grouped_count_by_week(current_quarter.start_date, current_quarter.end_date)
  end

  def current_quarter
    @_current_quarter ||= company.time_periods.current_quarter
  end

  def current_quarter_number
    @_current_quarter_number ||= /\d/.match(weeks_for_current_quarter.first.period_name)[0].to_i
  end

  def current_quarter_year
    @_current_quarter_year ||= /\d{4}/.match(weeks_for_current_quarter.first.period_name)[0].to_i
  end

  def weeks_for_current_quarter
    @_weeks_for_current_quarter ||= TimePeriodWeek.by_period_start_and_end(current_quarter.start_date,
                                                                           current_quarter.end_date)
  end

  def current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      deals_for_current_quarter.map do |key, value|
        memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
      end
    end
  end

  def deals_for_previous_quarter
    @_deals_for_previous_quarter ||=
        company.deals.grouped_count_by_week(previous_quarter.start_date, previous_quarter.end_date)
  end

  def previous_quarter
    @_previous_quarter ||= company.time_periods.all_quarter.find_by(
        start_date: time_period_week_for_previous_quarter.period_start,
        end_date: time_period_week_for_previous_quarter.period_end
    )
  end

  def time_period_week_for_previous_quarter
    @_time_period_week_for_previous_quarter ||=
        TimePeriodWeek.find_by(period_name: "Q#{previous_quarter_number}-#{previous_quarter_year}")
  end

  def previous_quarter_number
    current_quarter_number.eql?(FIRST_QUARTER_NUMBER) ? LAST_QUARTER_NUMBER : current_quarter_number - 1
  end

  def previous_quarter_year
    current_quarter_number.eql?(FIRST_QUARTER_NUMBER) ? current_quarter_year - 1 : current_quarter_year
  end

  def weeks_for_previous_quarter
    @_weeks_for_previous_quarter ||= TimePeriodWeek.by_period_start_and_end(previous_quarter.start_date,
                                                                            previous_quarter.end_date)
  end

  def previous_quarter_series
    return {} if previous_quarter.nil?

    weeks_for_previous_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      deals_for_previous_quarter.map do |key, value|
        memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
      end
    end
  end

  def deals_for_previous_year_quarter
    @_deals_for_previous_year_quarter ||=
        company.deals.grouped_count_by_week(previous_year_quarter.start_date, previous_year_quarter.end_date)
  end

  def previous_year_quarter
    @_previous_year_quarter ||= company.time_periods.all_quarter.find_by(
        start_date: time_period_week_for_previous_year_quarter.period_start,
        end_date: time_period_week_for_previous_year_quarter.period_end
    )
  end

  def time_period_week_for_previous_year_quarter
    @_time_period_week_for_previous_year_quarter ||=
        TimePeriodWeek.find_by(period_name: "Q#{current_quarter_number}-#{previous_year_quarter_year}")
  end

  def previous_year_quarter_year
    current_quarter_year - 1
  end

  def weeks_for_previous_year_quarter
    @_weeks_for_previous_year_quarter ||= TimePeriodWeek.by_period_start_and_end(previous_year_quarter.start_date,
                                                                                 previous_year_quarter.end_date)
  end

  def previous_year_quarter_series
    return {} if previous_year_quarter.nil?

    weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      deals_for_previous_year_quarter.map do |key, value|
        memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
      end
    end
  end

  def won_deals_for_current_quarter
    @_won_deals_for_current_quarter ||=
        company.deals.grouped_sum_budget_by_week(current_quarter.start_date, current_quarter.end_date)
  end

  def won_current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      won_deals_for_current_quarter.map do |key, value|
        memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
      end
    end
  end

  def won_deals_for_previous_quarter
    @_won_deals_for_previous_quarter ||=
        company.deals.grouped_sum_budget_by_week(previous_quarter.start_date, previous_quarter.end_date)
  end

  def won_previous_quarter_series
    return {} if previous_quarter.nil?

    weeks_for_previous_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      won_deals_for_previous_quarter.map do |key, value|
        memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
      end
    end
  end

  def won_deals_for_previous_year_quarter
    @_won_deals_for_previous_year_quarter ||=
        company.deals.grouped_sum_budget_by_week(previous_year_quarter.start_date, previous_year_quarter.end_date)
  end

  def won_previous_year_quarter_series
    return {} if previous_year_quarter.nil?

    weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      won_deals_for_previous_year_quarter.map do |key, value|
        memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
      end
    end
  end
end
