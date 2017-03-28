class AddBillingStatusAndManualOverrideToContentFeeProductBudgets < ActiveRecord::Migration
  def change
    add_column :content_fee_product_budgets, :billing_status, :string, default: ContentFeeProductBudget::PENDING
    add_column :content_fee_product_budgets, :manual_override, :boolean, default: false
  end
end
