class AddNewColumnsToAccountRevenueFacts < ActiveRecord::Migration
  def change
    add_reference :account_revenue_facts, :client_region, index: true
    add_reference :account_revenue_facts, :client_segment, index: true
    add_column :account_revenue_facts, :team_name, :string
    add_column :account_revenue_facts, :seller_names, :string, array: true, default: []
    add_index :account_revenue_facts, :team_name, length: 10
    add_index :account_revenue_facts, :seller_names, using: 'gin'
  end
end
