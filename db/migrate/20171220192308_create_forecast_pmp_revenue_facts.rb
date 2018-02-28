class CreateForecastPmpRevenueFacts < ActiveRecord::Migration
  def change
    create_table :forecast_pmp_revenue_facts do |t|
      t.belongs_to :forecast_time_dimension, index: true, foreign_key: true
      t.belongs_to :user_dimension, index: true, foreign_key: true
      t.belongs_to :product_dimension, index: true, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2
      t.jsonb :monthly_amount

      t.timestamps null: false
    end
  end
end
