class PacingDashboard::PipelineAndRevenueCalculationService
	def initialize(company)
		@company = company
	end

	def perform
		{
			pipeline_and_revenue: PacingDashboard::PipelineAndRevenueService.new(company).perform
		}
	end

	private

	attr_reader :company
end
