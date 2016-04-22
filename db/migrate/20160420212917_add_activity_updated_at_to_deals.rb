class AddActivityUpdatedAtToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :activity_updated_at, :datetime
  end
end
