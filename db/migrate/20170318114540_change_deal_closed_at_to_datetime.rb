class ChangeDealClosedAtToDatetime < ActiveRecord::Migration
  def change
    change_column :deals, :closed_at, :datetime
  end
end
