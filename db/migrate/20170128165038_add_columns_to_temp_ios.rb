class AddColumnsToTempIos < ActiveRecord::Migration
  def change
    change_column :temp_ios, :budget, :decimal, precision: 15, scale: 2, default: 0
    add_column :temp_ios, :budget_loc, :decimal, precision: 15, scale: 2, default: 0
    add_column :temp_ios, :curr_cd, :string, default: 'USD'
  end
end
