class CreateIos < ActiveRecord::Migration
  def change
    create_table :ios do |t|
      t.belongs_to :advertiser, index: true
      t.belongs_to :agency, index: true
      t.integer :budget
      t.datetime :start_date
      t.datetime :end_date
      t.integer :external_io_number
      t.integer :io_number

      t.timestamps null: false
    end
  end
end
