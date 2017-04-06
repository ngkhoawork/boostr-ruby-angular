class AddTypeAndVisibleToTimePeriod < ActiveRecord::Migration
  def change
    add_column :time_periods, :period_type, :string
    add_column :time_periods, :visible, :boolean, default: true
  end
end
