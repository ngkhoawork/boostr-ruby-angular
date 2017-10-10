class CreateAccountProductRevenueFacts < ActiveRecord::Migration
  def change
    create_table :account_product_revenue_facts do |t|
      t.references :account_dimension, index: true, foreign_key: true
      t.references :time_dimension, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      t.integer :revenue_amount

      t.timestamps null: false
    end
  end
end
