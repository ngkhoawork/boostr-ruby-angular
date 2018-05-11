class AddInvoiceNumberToDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    add_column :display_line_item_budgets, :invoice_id, :integer
  end
end
