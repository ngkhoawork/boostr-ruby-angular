class ChangeSnapshotDayToIntgerOnCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :snapshot_day
    add_column :companies, :snapshot_day, :integer, default: 0
  end
end
