class AddSalesProcessToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :sales_process_id, :integer
    add_index :teams, :sales_process_id
  end
end
