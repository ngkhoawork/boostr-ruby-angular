class AddUniqueIndexAndDeletedAtToSalesProcesses < ActiveRecord::Migration
  def change
    add_index :sales_processes, [:company_id, :name], unique: true
    add_column :sales_processes, :deleted_at, :datetime
    add_index :sales_processes, :deleted_at
  end
end
