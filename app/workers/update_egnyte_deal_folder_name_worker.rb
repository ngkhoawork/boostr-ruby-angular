class UpdateEgnyteDealFolderNameWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, deal_id)
    Egnyte::Actions::UpdateFolderName::Deal.new(
      egnyte_integration_id: egnyte_integration_id,
      deal_id: deal_id
    ).perform
  end
end
