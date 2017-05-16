class PacingDashboard::PipelineAndRevenueCalculationService
	def initialize(company, params)
		@company = company
		@params = params
	end

	def perform
		{
			pipeline_and_revenue: PacingDashboard::PipelineAndRevenueService.new(company, params).perform
		}
	end

	private

	attr_reader :company, :params
end
