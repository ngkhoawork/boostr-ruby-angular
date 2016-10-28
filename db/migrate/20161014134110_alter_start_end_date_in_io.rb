class AlterStartEndDateInIo < ActiveRecord::Migration
  def change
    change_column :ios, :start_date, :date
    change_column :ios, :end_date, :date
  end
end
