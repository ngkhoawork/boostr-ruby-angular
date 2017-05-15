module PacingDashboard
	class WonDealService < BaseService
		def perform
			{
				current_quarter: won_current_quarter_series,
				previous_quarter: won_previous_quarter_series,
				previous_year_quarter: won_previous_year_quarter_series
			}
		end

		private

		def won_deals_for_current_quarter
			@_won_deals_for_current_quarter ||=
				deals.grouped_sum_budget_by_week(current_quarter.start_date, current_quarter.end_date)
		end

		def won_current_quarter_series
			weeks_for_current_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				won_deals_for_current_quarter.map do |key, value|
					memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
				end
			end.values
		end

		def won_deals_for_previous_quarter
			@_won_deals_for_previous_quarter ||=
				deals.grouped_sum_budget_by_week(previous_quarter.start_date, previous_quarter.end_date)
		end

		def won_previous_quarter_series
			return [] if previous_quarter.nil?

			weeks_for_previous_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				won_deals_for_previous_quarter.map do |key, value|
					memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
				end
			end.values
		end

		def won_deals_for_previous_year_quarter
			@_won_deals_for_previous_year_quarter ||=
				deals.grouped_sum_budget_by_week(previous_year_quarter.start_date, previous_year_quarter.end_date)
		end

		def won_previous_year_quarter_series
			return [] if previous_year_quarter.nil?

			weeks_for_previous_year_quarter.each_with_object({}) do |week, memo|
				memo[week.start_date] = 0

				won_deals_for_previous_year_quarter.map do |key, value|
					memo[week.start_date] += value.to_i if week.start_date <= key && week.end_date >= key
				end
			end.values
		end
	end
end
