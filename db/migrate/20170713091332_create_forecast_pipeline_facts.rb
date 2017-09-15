class CreateForecastPipelineFacts < ActiveRecord::Migration
  def change
    create_table :forecast_pipeline_facts do |t|
      t.belongs_to :time_dimension, index: true, foreign_key: true
      t.belongs_to :user_dimension, index: true, foreign_key: true
      t.belongs_to :product_dimension, index: true, foreign_key: true
      t.belongs_to :stage_dimension, index: true, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2

      t.timestamps null: false
    end
  end
end
