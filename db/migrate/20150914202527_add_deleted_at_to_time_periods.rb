class AddDeletedAtToTimePeriods < ActiveRecord::Migration
  def change
    add_column :time_periods, :deleted_at, :datetime

    add_index :time_periods, :deleted_at
  end
end
