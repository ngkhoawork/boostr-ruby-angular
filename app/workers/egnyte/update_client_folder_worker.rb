class Egnyte::UpdateClientFolderWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, client_id, parent_changed)
    Egnyte::Actions::UpdateFolder::Account.new(
      egnyte_integration_id: egnyte_integration_id,
      client_id: client_id,
      parent_changed: parent_changed
    ).perform
  end
end
