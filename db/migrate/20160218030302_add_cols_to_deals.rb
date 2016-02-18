class AddColsToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :stage_updated_by, :integer
    add_column :deals, :stage_updated_at, :datetime
    add_column :deals, :updated_by, :integer
  end
end
