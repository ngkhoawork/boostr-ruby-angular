class SetupEgnyteDealFoldersWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, deal_name, advertiser_name)
    Egnyte::Actions::CreateFolderTree::Deal.new(
      egnyte_integration_id: egnyte_integration_id,
      deal_name: deal_name,
      advertiser_name: advertiser_name
    ).perform
  end
end
