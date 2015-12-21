class AddStartDateAndEndDateToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :start_date, :datetime
    add_column :snapshots, :end_date, :datetime

    add_index :snapshots, :start_date
    add_index :snapshots, :end_date
  end
end
