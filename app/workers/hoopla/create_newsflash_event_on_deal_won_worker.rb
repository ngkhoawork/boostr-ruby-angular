class Hoopla::CreateNewsflashEventOnDealWonWorker < BaseWorker
  def perform(deal_id, user_id, company_id)
    Hoopla::Actions::CreateNewsflashEventOnDealWon.new(
      deal_id: deal_id,
      user_id: user_id,
      company_id: company_id
    ).perform
  end
end
