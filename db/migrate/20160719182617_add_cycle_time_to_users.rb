class AddCycleTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cycle_time, :float
  end
end
