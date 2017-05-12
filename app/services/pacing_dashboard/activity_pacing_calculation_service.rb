class PacingDashboard::ActivityPacingCalculationService
	def initialize(company)
		@company = company
	end

	def perform
		{
			new_deals: PacingDashboard::NewDealService.new(company).perform,
			won_deals: PacingDashboard::WonDealService.new(company).perform
		}
	end

	private

	attr_reader :company
end
