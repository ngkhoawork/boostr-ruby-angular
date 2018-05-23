class Hoopla::SyncCompaniesUsersWorker < BaseWorker
  def perform
    Hoopla::Actions::SyncCompaniesUsers.perform
  end
end
