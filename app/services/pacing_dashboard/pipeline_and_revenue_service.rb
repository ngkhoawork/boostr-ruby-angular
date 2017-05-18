class PacingDashboard::PipelineAndRevenueService < PacingDashboard::BaseService
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
			snapshot_grouped_by_day_for_current_quarter.sum(:weighted_pipeline)
			.merge(snapshot_grouped_by_day_for_current_quarter.sum(:revenue)) do |_key, revenue_val, pipeline_val|
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
		end.values
	end

	def max_weighted_pipeline_by_week_for_current_quarter_series
		weeks_for_current_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_weighted_pipeline_by_day_for_current_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end.values
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_current_quarter_series
		weeks_for_current_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter.map do |key, _value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] += snapshot_sum_revenue_and_weighted_pipeline_for_current_quarter.delete(key)
				end
			end
		end.values
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
			snapshot_grouped_by_day_for_previous_quarter.sum(:weighted_pipeline)
			.merge(snapshot_grouped_by_day_for_previous_quarter.sum(:revenue)) do |_key, revenue_val, pipeline_val|
				revenue_val + pipeline_val
			end
	end

	def max_revenue_by_week_for_previous_quarter_series
		return empty_weeks_data if previous_quarter.nil?

		weeks_for_previous_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_revenue_by_day_for_previous_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
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
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end.values
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_previous_quarter_series
		return empty_weeks_data if previous_quarter.nil?

		weeks_for_previous_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter.map do |key, _value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] += snapshot_sum_revenue_and_weighted_pipeline_for_previous_quarter.delete(key)
				end
			end
		end.values
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
			snapshot_grouped_by_day_for_previous_year_quarter.sum(:weighted_pipeline)
			.merge(snapshot_grouped_by_day_for_previous_year_quarter.sum(:revenue)) do |_key, revenue_val, pipeline_val|
				revenue_val + pipeline_val
			end
	end

	def max_revenue_by_week_for_previous_year_quarter_series
		return empty_weeks_data if previous_year_quarter.nil?

		weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_max_revenue_by_day_for_previous_year_quarter.map do |key, value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] = value if value > memo[week.start_date]
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
					memo[week.start_date] = value if value > memo[week.start_date]
				end
			end
		end.values
	end

	def sum_revenue_and_weighted_pipeline_by_week_for_previous_year_quarter_series
		return empty_weeks_data if previous_year_quarter.nil?

		weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
			memo[week.start_date] = 0

			snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter.map do |key, _value|
				if week.start_date <= key && week.end_date >= key
					memo[week.start_date] += snapshot_sum_revenue_and_weighted_pipeline_for_previous_year_quarter.delete(key)
				end
			end
		end.values
	end
end
