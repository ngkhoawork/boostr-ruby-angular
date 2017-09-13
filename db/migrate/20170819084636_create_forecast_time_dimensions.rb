class CreateForecastTimeDimensions < ActiveRecord::Migration
  def change
    create_table :forecast_time_dimensions do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :days_length

      t.timestamps null: false
    end
  end
end
