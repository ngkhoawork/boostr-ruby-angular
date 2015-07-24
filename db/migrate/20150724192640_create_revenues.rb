class CreateRevenues < ActiveRecord::Migration
  def change
    create_table :revenues do |t|
      t.integer :order_number
      t.string :ad_server
      t.integer :line_number
      t.integer :quantity
      t.integer :price
      t.string :price_type
      t.integer :delivered
      t.integer :remaining
      t.integer :budget
      t.integer :budget_remaining
      t.datetime :start_date
      t.datetime :end_date
      t.integer :company_id
      t.integer :client_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
