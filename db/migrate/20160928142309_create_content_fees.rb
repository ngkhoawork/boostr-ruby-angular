class CreateContentFees < ActiveRecord::Migration
  def change
    create_table :content_fees do |t|
      t.belongs_to :io, index: true, foreign_key: true
      t.integer :io_number
      t.integer :budget

      t.timestamps null: false
    end
  end
end
