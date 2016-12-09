class CreateDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    create_table :display_line_item_budgets do |t|
      t.belongs_to :display_line_item, index: true, foreign_key: true
      t.integer :external_io_number
      t.float :budget
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
