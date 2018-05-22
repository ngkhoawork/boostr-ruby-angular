class Hoopla::SyncCompanyUsersWorker < BaseWorker
  def perform(company_id)
    Hoopla::Actions::SyncCompanyUsers.new(company_id: company_id).perform
  end
end
