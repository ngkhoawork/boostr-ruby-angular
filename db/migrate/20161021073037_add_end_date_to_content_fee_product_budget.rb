class AddEndDateToContentFeeProductBudget < ActiveRecord::Migration
  def change
    rename_column :content_fee_product_budgets, :month, :start_date
    add_column :content_fee_product_budgets, :end_date, :date
  end
end
