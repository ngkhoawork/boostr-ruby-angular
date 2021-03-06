class Egnyte::UpdateDealFolderWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, deal_id, advertiser_changed)
    Egnyte::Actions::UpdateFolder::Deal.new(
      egnyte_integration_id: egnyte_integration_id,
      deal_id: deal_id,
      advertiser_changed: advertiser_changed
    ).perform
  end
end
