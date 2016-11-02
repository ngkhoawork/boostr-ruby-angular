class CreatePrintItems < ActiveRecord::Migration
  def change
    create_table :print_items do |t|
      t.belongs_to :io, index: true, foreign_key: true
      t.string :ad_unit
      t.string :ad_type
      t.integer :rate
      t.string :market
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
