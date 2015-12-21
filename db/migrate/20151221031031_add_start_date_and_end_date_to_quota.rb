class AddStartDateAndEndDateToQuota < ActiveRecord::Migration
  def change
    add_column :quota, :start_date, :datetime
    add_column :quota, :end_date, :datetime

    add_index :quota, :start_date
    add_index :quota, :end_date
  end
end
