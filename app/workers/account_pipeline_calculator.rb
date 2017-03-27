class AccountPipelineCalculator < BaseWorker
  def perform
    AccountPipelineCalculatorService.new.perform
  end
end