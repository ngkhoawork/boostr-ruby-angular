class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.belongs_to :io, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.string :type
      t.decimal :total_cost, precision: 15, scale: 2
      t.decimal :total_cost_loc, precision: 15, scale: 2
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
