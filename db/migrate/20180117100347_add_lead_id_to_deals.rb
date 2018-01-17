class AddLeadIdToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :lead_id, :integer
    add_index :deals, :lead_id
  end
end
