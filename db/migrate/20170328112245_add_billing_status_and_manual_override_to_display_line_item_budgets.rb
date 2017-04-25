class AddBillingStatusAndManualOverrideToDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    add_column :display_line_item_budgets, :billing_status, :string, default: DisplayLineItemBudget::PENDING
    add_column :display_line_item_budgets, :manual_override, :boolean, default: false
  end
end
