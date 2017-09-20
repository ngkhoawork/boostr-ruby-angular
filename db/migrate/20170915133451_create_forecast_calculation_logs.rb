class CreateForecastCalculationLogs < ActiveRecord::Migration
  def change
    create_table :forecast_calculation_logs do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :finished

      t.timestamps null: false
    end
  end
end
