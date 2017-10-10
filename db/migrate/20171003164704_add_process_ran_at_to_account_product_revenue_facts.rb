class AddProcessRanAtToAccountProductRevenueFacts < ActiveRecord::Migration
  def change
    add_column :account_product_revenue_facts, :process_ran_at, :datetime
  end
end
