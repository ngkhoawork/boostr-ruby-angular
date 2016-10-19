class AddDealProductIdToProductBudget < ActiveRecord::Migration
  def change
    add_reference :deal_product_budgets, :deal_product, foreign_key: true
  end
end
