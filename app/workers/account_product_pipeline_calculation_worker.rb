class AccountProductPipelineCalculationWorker < BaseWorker
  def perform
    Facts::AccountProductPipelineFactService.new.perform
  end
end