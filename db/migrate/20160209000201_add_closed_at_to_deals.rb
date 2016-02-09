class AddClosedAtToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :closed_at, :date
  end
end
