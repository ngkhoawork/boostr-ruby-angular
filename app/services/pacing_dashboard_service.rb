class PacingDashboardService
  FIRST_QUARTER_NUMBER = 1
  LAST_QUARTER_NUMBER = 4

  def initialize(company)
    @company = company
  end

  def perform
    {
      piepline_and_revenue: {
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
      },
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

  def snapshot_grouped_by_day_for_current_quarter
    @_snapshot_grouped_by_day_for_current_quarter ||=
      Snapshot.grouped_by_day_in_period_for_company(company, current_quarter)
  end

  def snapshot_max_revenue_by_day_for_current_quarter
    @_snapshot_max_revenue_by_day_for_current_quarter ||=
			snapshot_grouped_by_day_for_current_quarter.maximum(:revenue)
  end

  def snapshot_max_weighted_pipeline_by_day_for_current_quarter
    @_snapshot_max_weighted_pipeline_by_day_for_current_quarter ||=
			snapshot_grouped_by_day_for_current_quarter.maximum(:weighted_pipeline)
  end

  def snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter
    @_snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter ||=
			snapshot_max_revenue_by_day_for_current_quarter
			.merge(snapshot_max_weighted_pipeline_by_day_for_current_quarter) do |_key, revenue_val, pipeline_val|
				revenue_val + pipeline_val
			end
  end

  def max_revenue_by_week_for_current_quarter_series
    weeks_for_current_quarter.each_with_object({}) do |week, memo|
      memo[week.start_date] = 0

      snapshot_max_revenue_by_day_for_current_quarter.map do |key, value|
        if week.start_date <= key && week.end_date >= key
          memo[week.start_date] = value if value > memo[week.start_date]
        end
      end
    end
	end

	def max_weighted_pipeline_by_week_for_current_quarter_series
		weeks_for_current_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_weighted_pipeline_by_day_for_current_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_current_quarter_series
		weeks_for_current_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

  def snapshot_grouped_by_day_for_previous_quarter
    @_snapshot_grouped_by_day_for_previous_quarter ||=
      Snapshot.grouped_by_day_in_period_for_company(company, previous_quarter)
	end

	def snapshot_max_revenue_by_day_for_previous_quarter
		@_snapshot_max_revenue_by_day_for_previous_quarter ||=
			snapshot_grouped_by_day_for_previous_quarter.maximum(:revenue)
	end

	def snapshot_max_weighted_pipeline_by_day_for_previous_quarter
		@_snapshot_max_weighted_pipeline_by_day_for_previous_quarter ||=
			snapshot_grouped_by_day_for_previous_quarter.maximum(:weighted_pipeline)
	end

	def snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter
		@_snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter ||=
			snapshot_max_revenue_by_day_for_previous_quarter
			.merge(snapshot_max_weighted_pipeline_by_day_for_previous_quarter) do |_key, revenue_val, pipeline_val|
				revenue_val + pipeline_val
			end
	end

	def max_revenue_by_week_for_previous_quarter_series
		return {} if previous_quarter.nil?

		weeks_for_previous_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_revenue_by_day_for_previous_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def max_weighted_pipeline_by_week_for_previous_quarter_series
		return {} if previous_quarter.nil?

		weeks_for_previous_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_weighted_pipeline_by_day_for_previous_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_previous_quarter_series
		return {} if previous_quarter.nil?

		weeks_for_previous_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def snapshot_grouped_by_day_for_previous_year_quarter
		@_snapshot_grouped_by_day_for_previous_year_quarter ||=
			Snapshot.grouped_by_day_in_period_for_company(company, previous_year_quarter)
	end

	def snapshot_max_revenue_by_day_for_previous_year_quarter
		@_snapshot_max_revenue_by_day_for_previous_year_quarter ||=
			snapshot_grouped_by_day_for_previous_year_quarter.maximum(:revenue)
	end

	def snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter
		@_snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter ||=
			snapshot_grouped_by_day_for_previous_year_quarter.maximum(:weighted_pipeline)
	end

	def snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter
		@_snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter ||=
			snapshot_max_revenue_by_day_for_previous_year_quarter
			.merge(snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter) do |_key, revenue_val, pipeline_val|
				revenue_val + pipeline_val
			end
	end

	def max_revenue_by_week_for_previous_year_quarter_series
		return {} if previous_year_quarter.nil?

		weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_revenue_by_day_for_previous_year_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def max_weighted_pipeline_by_week_for_previous_year_quarter_series
		return {} if previous_year_quarter.nil?

		weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_weighted_pipeline_by_day_for_previous_year_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_previous_year_quarter_series
		return {} if previous_year_quarter.nil?

		weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end
	end
end
