class OperativeIntegrationWorker < BaseWorker
  def perform(deal)
    Operative::IntegrationService.new(deal).perform
  end
end
