class AddCvKeysToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :type_id, :integer
    add_index :deals, :type_id
    add_column :deals, :source_id, :integer
    add_index :deals, :source_id
    add_column :deals, :close_reason_id, :integer
    add_index :deals, :close_reason_id
  end
end