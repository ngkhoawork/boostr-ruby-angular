class AddYearAndQuarterToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :year, :integer
    add_column :snapshots, :quarter, :integer

    add_index :snapshots, [:year, :quarter]
  end
end
