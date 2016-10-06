class GenerateDealProductData < ActiveRecord::Migration
  def change
    DealProductBudget.update_all(deal_product_id: nil)
    DealProduct.delete_all
    deals = Deal.with_deleted
    deals.each do |deal|
      budget = 0
      product_id = nil
      start_date = nil
      end_date = nil
      deal_product_budgets = DealProductBudget.where(deal_id: deal.id).order("product_id asc, start_date asc")
      deal_product_budgets.each do |deal_product_budget|
        if product_id != deal_product_budget.product_id
          if product_id != nil
            deal_product_param = {
                deal_id: deal_product_budget.deal_id,
                product_id: product_id,
                budget: budget,
                start_date: start_date,
                end_date: end_date,
                open: deal.stage.probability != 100
            }
            deal_product = DealProduct.create(deal_product_param)
            DealProductBudget.where(product_id: product_id, deal_id: deal.id).update_all(deal_product_id: deal_product.id)
          end
          start_date = deal_product_budget.start_date
          budget = 0
          product_id = deal_product_budget.product_id
        end
        end_date = deal_product_budget.end_date
        budget += deal_product_budget.budget
      end
      if product_id.present?
        deal_product_param = {
            deal_id: deal.id,
            product_id: product_id,
            budget: budget,
            start_date: start_date,
            end_date: end_date,
            open: deal.stage.probability != 100
        }
        deal_product = DealProduct.create(deal_product_param)
        DealProductBudget.where(product_id: product_id, deal_id: deal.id).update_all(deal_product_id: deal_product.id)
      end

    end
  end
end
