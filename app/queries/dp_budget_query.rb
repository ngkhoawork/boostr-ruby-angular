class DpBudgetQuery
  attr_reader :options

  def initialize(options = {}, relation = DealProductBudget.all)
    @options = options
    @relation = relation
  end

  def all
    @result ||= @relation.joins("INNER JOIN deal_products ON deal_product_budgets.deal_product_id = deal_products.id")
             .joins("INNER JOIN deals ON deal_products.deal_id = deals.id")
             .joins("INNER JOIN stages ON deals.stage_id = stages.id")
             .where("(deals.advertiser_id = ? OR deals.agency_id = ?) AND deals.company_id = ? AND deal_products.open IS FALSE", options[:client_id], options[:client_id], options[:company_id])
             .select("deal_product_budgets.*, stages.probability as stage_prob, deals.id as deal_id")
  end
end