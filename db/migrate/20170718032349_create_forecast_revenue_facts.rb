class CreateForecastRevenueFacts < ActiveRecord::Migration
  def change
    create_table :forecast_revenue_facts do |t|
      t.belongs_to :time_dimension, index: true, foreign_key: true
      t.belongs_to :user_dimension, index: true, foreign_key: true
      t.belongs_to :product_dimension, index: true, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2
      t.jsonb :monthly_amount

      t.timestamps null: false
    end
    add_index  :forecast_revenue_facts, :monthly_amount, using: :gin
  end
end
