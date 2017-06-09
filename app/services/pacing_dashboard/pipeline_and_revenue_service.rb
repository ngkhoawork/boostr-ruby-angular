class PacingDashboard::PipelineAndRevenueService < PacingDashboard::BaseService
  FIRST_NEGATIVE_WEEK = -8
  FIRST_POSITIVE_WEEK = 1
  LAST_WEEK = 13

  def perform
    {
      revenue: {
        current_quarter: max_revenue_by_week_for_current_quarter_series,
        previous_quarter: max_revenue_by_week_for_previous_quarter_series,
        previous_year_quarter: max_revenue_by_week_for_previous_year_quarter_series
      },
      weighted_pipeline: {
        current_quarter: max_weighted_pipeline_by_week_for_current_quarter_series,
        previous_quarter: max_weighted_pipeline_by_week_for_previous_quarter_series,
        previous_year_quarter: max_weighted_pipeline_by_week_for_previous_year_quarter_series
      },
      sum_revenue_and_weighted_pipeline: {
        current_quarter: sum_revenue_and_weighted_pipeline_by_week_for_current_quarter_series,
        previous_quarter: sum_revenue_and_weighted_pipeline_by_week_for_previous_quarter_series,
        previous_year_quarter: sum_revenue_and_weighted_pipeline_by_week_for_previous_year_quarter_series
      }
    }
  end

  private

  def use_all_time_period_weeks?
    true
  end

  def start_date_for_current_quarter
    weeks_for_current_quarter.find_by(week: FIRST_NEGATIVE_WEEK).start_date
  end

  def end_date_for_current_quarter
    weeks_for_current_quarter.find_by(week: LAST_WEEK).end_date
  end

  def start_date_for_previous_quarter
    weeks_for_previous_quarter.find_by(week: FIRST_NEGATIVE_WEEK).start_date
  end

  def end_date_for_previous_quarter
    weeks_for_previous_quarter.find_by(week: LAST_WEEK).end_date
  end

  def start_date_for_previous_year_quarter
    weeks_for_previous_year_quarter.find_by(week: FIRST_NEGATIVE_WEEK).start_date
  end

  def end_date_for_previous_year_quarter
    weeks_for_previous_year_quarter.find_by(week: LAST_WEEK).end_date
  end

  def snapshot_grouped_by_day_for_current_quarter
    @_snapshot_grouped_by_day_for_current_quarter ||=
      Snapshot
        .by_company_in_period(company, current_quarter, start_date_for_current_quarter, end_date_for_current_quarter)
        .grouped_by_day_in_period_for_company
  end

  def snapshot_max_revenue_by_day_for_current_quarter
    @_snapshot_max_revenue_by_day_for_current_quarter ||=
      snapshot_grouped_by_day_for_current_quarter.sum(:revenue)
  end

  def snapshot_max_weighted_pipeline_by_day_for_current_quarter
    @_snapshot_max_weighted_pipeline_by_day_for_current_quarter ||=
      snapshot_grouped_by_day_for_current_quarter.sum(:weighted_pipeline)
  end

  def snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter
    @_snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter ||=
      snapshot_grouped_by_day_for_current_quarter.sum('revenue + weighted_pipeline')
  end

  def max_revenue_by_week_for_current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = nil

      snapshot_max_revenue_by_day_for_current_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def max_weighted_pipeline_by_week_for_current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = nil

      snapshot_max_weighted_pipeline_by_day_for_current_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def sum_revenue_and_weighted_pipeline_by_week_for_current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = nil

      snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def snapshot_grouped_by_day_for_previous_quarter
    @_snapshot_grouped_by_day_for_previous_quarter ||=
      Snapshot
        .by_company_in_period(company, previous_quarter, start_date_for_previous_quarter, end_date_for_previous_quarter)
        .grouped_by_day_in_period_for_company
  end

  def snapshot_max_revenue_by_day_for_previous_quarter
    @_snapshot_max_revenue_by_day_for_previous_quarter ||=
      snapshot_grouped_by_day_for_previous_quarter.sum(:revenue)
  end

  def snapshot_max_weighted_pipeline_by_day_for_previous_quarter
    @_snapshot_max_weighted_pipeline_by_day_for_previous_quarter ||=
      snapshot_grouped_by_day_for_previous_quarter.sum(:weighted_pipeline)
  end

  def snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter
    @_snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter ||=
      snapshot_grouped_by_day_for_previous_quarter.sum('revenue + weighted_pipeline')
  end

  def max_revenue_by_week_for_previous_quarter_series
    return empty_weeks_data if previous_quarter.nil?

    weeks_for_previous_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_max_revenue_by_day_for_previous_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def max_weighted_pipeline_by_week_for_previous_quarter_series
    return empty_weeks_data if previous_quarter.nil?

    weeks_for_previous_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_max_weighted_pipeline_by_day_for_previous_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def sum_revenue_and_weighted_pipeline_by_week_for_previous_quarter_series
    return empty_weeks_data if previous_quarter.nil?

    weeks_for_previous_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def snapshot_grouped_by_day_for_previous_year_quarter
    @_snapshot_grouped_by_day_for_previous_year_quarter ||=
      Snapshot
        .by_company_in_period(company,
                              previous_year_quarter,
                              start_date_for_previous_year_quarter,
                              end_date_for_previous_year_quarter)
        .grouped_by_day_in_period_for_company
  end

  def snapshot_max_revenue_by_day_for_previous_year_quarter
    @_snapshot_max_revenue_by_day_for_previous_year_quarter ||=
      snapshot_grouped_by_day_for_previous_year_quarter.sum(:revenue)
  end

  def snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter
    @_snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter ||=
      snapshot_grouped_by_day_for_previous_year_quarter.sum(:weighted_pipeline)
  end

  def snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter
    @_snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter ||=
      snapshot_grouped_by_day_for_previous_year_quarter.sum('revenue + weighted_pipeline')
  end

  def max_revenue_by_week_for_previous_year_quarter_series
    return empty_weeks_data if previous_year_quarter.nil?

    weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_max_revenue_by_day_for_previous_year_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def max_weighted_pipeline_by_week_for_previous_year_quarter_series
    return empty_weeks_data if previous_year_quarter.nil?

    weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end

  def sum_revenue_and_weighted_pipeline_by_week_for_previous_year_quarter_series
    return empty_weeks_data if previous_year_quarter.nil?

    weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if key >= week.start_date
        end
      end
    end.values
  end
end
