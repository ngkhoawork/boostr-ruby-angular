class CreateBps < ActiveRecord::Migration
  def change
    create_table :bps do |t|
      t.string :name
      t.belongs_to :time_period, index: true, foreign_key: true
      t.date :due_date
      t.belongs_to :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
