class Hoopla::BindCompanyUsersWorker < BaseWorker
  def perform(company_id)
    Hoopla::Actions::BindCompanyUsers.new(company_id: company_id).perform
  end
end
