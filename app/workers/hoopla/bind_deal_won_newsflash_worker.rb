class Hoopla::BindDealWonNewsflashWorker < BaseWorker
  def perform(company_id)
    Hoopla::Actions::BindDealWonNewsflash.new(company_id: company_id).perform
  end
end
