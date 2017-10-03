class AccountProductRevenueCalculationWorker < BaseWorker
  def perform
    Facts::AccountProductRevenueFactService.new.perform
  end
end