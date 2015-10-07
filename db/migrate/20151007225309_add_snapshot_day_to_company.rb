class AddSnapshotDayToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :snapshot_day, :string, default: 'Sunday'
  end
end
