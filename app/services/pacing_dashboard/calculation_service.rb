class PacingDashboard::CalculationService
	def initialize(company)
		@company = company
	end

	def perform
		{
			pipeline_and_revenue: PacingDashboard::PipelineAndRevenueService.new(company).perform,
			new_deals: PacingDashboard::NewDealService.new(company).perform,
			won_deals: PacingDashboard::WonDealService.new(company).perform
		}
	end

	private

	attr_reader :company
end
