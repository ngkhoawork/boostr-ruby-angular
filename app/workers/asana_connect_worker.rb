class AsanaConnectWorker < BaseWorker
  def perform(deal_id)
    AsanaConnect::IntegrationService.new(deal_id).perform
  end
end
