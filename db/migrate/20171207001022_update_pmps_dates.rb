class UpdatePmpsDates < ActiveRecord::Migration
  def up
    change_column :pmps, :start_date, :date
    change_column :pmps, :end_date, :date
  end

  def down
    change_column :pmps, :start_date, :datetime
    change_column :pmps, :end_date, :datetime
  end
end
