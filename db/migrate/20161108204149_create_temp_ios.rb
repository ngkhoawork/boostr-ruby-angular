class CreateTempIos < ActiveRecord::Migration
  def change
    create_table :temp_ios do |t|
      t.string :name
      t.belongs_to :company, index: true, foreign_key: true
      t.string :advertiser
      t.string :agency
      t.bigint :budget
      t.date :start_date
      t.date :end_date
      t.integer :external_io_number

      t.timestamps null: false
    end
  end
end
