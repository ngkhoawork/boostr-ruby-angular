class CopyDealProductBudgets < ActiveRecord::Migration
  def change
    deal_products = DealProduct.all.order("id asc")
    deal_products.each do |deal_product|
      DealProductBudget.create!({
          deal_id: deal_product.deal_id,
          product_id: deal_product.product.nil? ? nil : deal_product.product.id,
          budget: deal_product.budget / 100,
          period: deal_product.period,
          start_date: deal_product.start_date,
          end_date: deal_product.end_date
      })
    end
  end
end
