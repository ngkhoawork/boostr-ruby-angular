class AddDeletedAtToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :deleted_at, :datetime
    add_index :deals, :deleted_at
  end
end
