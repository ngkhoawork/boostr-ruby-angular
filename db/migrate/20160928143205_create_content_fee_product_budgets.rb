class CreateContentFeeProductBudgets < ActiveRecord::Migration
  def change
    create_table :content_fee_product_budgets do |t|
      t.belongs_to :content_fee, index: true, foreign_key: true
      t.integer :budget
      t.date :month

      t.timestamps null: false
    end
  end
end
