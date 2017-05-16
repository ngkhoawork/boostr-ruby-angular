class PacingDashboard::ActivityPacingCalculationService
	def initialize(company, params)
		@company = company
		@params = params
	end

	def perform
		{
			new_deals: PacingDashboard::NewDealService.new(company, params).perform,
			won_deals: PacingDashboard::WonDealService.new(company, params).perform
		}
	end

	private

	attr_reader :company, :params
end
