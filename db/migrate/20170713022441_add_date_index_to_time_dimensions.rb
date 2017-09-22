class AddDateIndexToTimeDimensions < ActiveRecord::Migration
  def change
  	add_index :time_dimensions, [:start_date, :end_date]
  end
end
