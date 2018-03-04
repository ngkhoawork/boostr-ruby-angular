class UpdateEgnyteClientFolderNameWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, advertiser_id)
    Egnyte::Actions::UpdateFolderName::Account.new(
      egnyte_integration_id: egnyte_integration_id,
      advertiser_id: advertiser_id
    ).perform
  end
end
