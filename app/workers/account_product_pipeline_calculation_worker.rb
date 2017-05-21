class AccountProductPipelineCalculationWorker < BaseWorker
  def perform
    AccountProductPipelineFactService.new.perform
  end
end