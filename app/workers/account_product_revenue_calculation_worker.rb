class AccountProductRevenueCalculationWorker < BaseWorker
  def perform
    AccountProductRevenueFactService.new.perform
  end

end