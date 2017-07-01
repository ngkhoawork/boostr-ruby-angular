class AsanaConnectWorker < BaseWorker
  def perform(deal_id)
    if asana_integration_required?(deal_id)
      AsanaConnect::IntegrationService.new(deal_id).perform
    end
  end

  private

  def asana_integration_required?(deal_id)
    deal = Deal.find_by_id deal_id
    if deal.present?
      config = deal.company.asana_connect_config
      config.present? && config.switched_on?
    end
  end
end
