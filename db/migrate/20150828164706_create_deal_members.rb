class CreateDealMembers < ActiveRecord::Migration
  def change
    create_table :deal_members do |t|
      t.integer :deal_id
      t.integer :user_id
      t.integer :share
      t.string :role

      t.timestamps null: false
    end
  end
end
