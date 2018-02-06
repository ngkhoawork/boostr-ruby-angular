class SetupEgnyteDealFoldersWorker < BaseWorker
  sidekiq_options retry: 3

  def perform(egnyte_integration_id, root_name)
    Egnyte::Actions::CreateFolderTree::Deal.new(
      egnyte_integration_id: egnyte_integration_id,
      root_name: root_name
    ).perform
  end
end
