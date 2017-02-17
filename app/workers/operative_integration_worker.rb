class OperativeIntegrationWorker < BaseWorker
  def perform(deal_id)
    Operative::IntegrationService.new(deal_id).perform
  end
end
