class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :name
      t.text :comment
      t.integer :user_id
      t.integer :remindable_id
      t.string :remindable_type
      t.datetime :remind_on

      t.timestamps null: false
    end
  end
end
