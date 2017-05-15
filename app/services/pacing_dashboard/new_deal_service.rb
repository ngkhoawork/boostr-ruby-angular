module PacingDashboard
	class NewDealService < BaseService
		def perform
			{
				current_quarter: current_quarter_series,
				previous_quarter: previous_quarter_series,
				previous_year_quarter: previous_year_quarter_series
			}
		end

		private

		def deals_for_current_quarter
			@_deals_for_current_quarter ||=
				deals.grouped_count_by_week(current_quarter.start_date, current_quarter.end_date)
		end

		def current_quarter_series
			weeks_for_current_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				deals_for_current_quarter.map do |key, value|
					memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
				end
			end.values
		end

		def deals_for_previous_quarter
			@_deals_for_previous_quarter ||=
				deals.grouped_count_by_week(previous_quarter.start_date, previous_quarter.end_date)
		end

		def previous_quarter_series
			return empty_weeks_data if previous_quarter.nil?

			weeks_for_previous_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				deals_for_previous_quarter.map do |key, value|
					memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
				end
			end.values
		end

		def deals_for_previous_year_quarter
			@_deals_for_previous_year_quarter ||=
				deals.grouped_count_by_week(previous_year_quarter.start_date, previous_year_quarter.end_date)
		end

		def previous_year_quarter_series
			return empty_weeks_data if previous_year_quarter.nil?

			weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				deals_for_previous_year_quarter.map do |key, value|
					memo[week.start_date] += value if week.start_date <= key && week.end_date >= key
				end
			end.values
		end
	end
end
