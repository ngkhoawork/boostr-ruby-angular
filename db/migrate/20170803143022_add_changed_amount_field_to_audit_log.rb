class AddChangedAmountFieldToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :changed_amount, :string
  end
end
