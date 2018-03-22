class CreateCostMonthlyAmounts < ActiveRecord::Migration
  def change
    create_table :cost_monthly_amounts do |t|
      t.belongs_to :cost, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :cost, precision: 15, scale: 2
      t.decimal :cost_loc, precision: 15, scale: 2

      t.timestamps null: false
    end
  end
end
