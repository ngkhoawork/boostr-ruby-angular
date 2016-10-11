class NormalizeDealProductColumns < ActiveRecord::Migration
  def change
    remove_column :deal_products, :start_date
    remove_column :deal_products, :end_date
    remove_column :deal_product_budgets, :deal_id
    remove_column :deal_product_budgets, :product_id
  end
end
