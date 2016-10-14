class CreateIoMembers < ActiveRecord::Migration
  def change
    create_table :io_members do |t|
      t.belongs_to :ios, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :share
      t.date :from_date
      t.date :to_date

      t.timestamps null: false
    end
  end
end
