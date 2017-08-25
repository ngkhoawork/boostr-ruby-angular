class AddChangedAmountFieldToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :changed_amount, :decimal, precision: 15, scale: 2
  end
end
