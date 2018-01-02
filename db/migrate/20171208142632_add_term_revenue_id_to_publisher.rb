class AddTermRevenueIdToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :renewal_term_id, :integer
    add_index :publishers, :renewal_term_id
  end
end
