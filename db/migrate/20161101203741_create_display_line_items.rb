class CreateDisplayLineItems < ActiveRecord::Migration
  def change
    create_table :display_line_items do |t|
      t.belongs_to :io, index: true, foreign_key: true
      t.integer :line_number
      t.string :ad_server
      t.integer :quantity
      t.bigint :budget
      t.string :pricing_type
      t.belongs_to :product, index: true, foreign_key: true
      t.bigint :budget_delivered
      t.bigint :budget_remaining
      t.integer :quantity_delivered
      t.integer :quantity_remaining
      t.date :start_date
      t.date :end_date
      t.integer :daily_run_rate
      t.bigint :num_days_til_out_of_budget
      t.integer :quantity_delivered_3p
      t.integer :quantity_remaining_3p
      t.bigint :budget_delivered_3p
      t.bigint :budget_remaining_3p

      t.timestamps null: false
    end
  end
end
