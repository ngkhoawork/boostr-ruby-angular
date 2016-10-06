class CreateDealProducts < ActiveRecord::Migration
  def change
    create_table :deal_products do |t|
      t.integer :deal_id
      t.integer :product_id
      t.integer :budget
      t.date :period

      t.timestamps null: false
    end
  end
end
