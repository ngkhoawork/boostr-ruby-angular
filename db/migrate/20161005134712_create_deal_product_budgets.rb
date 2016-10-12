class CreateDealProductBudgets < ActiveRecord::Migration
  def change
    change_column :deals, :budget, :bigint
    change_column :deal_products, :budget, :bigint
    create_table :deal_product_budgets do |t|
      t.belongs_to :deal, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.bigint :budget
      t.date :period
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
