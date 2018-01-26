class CreatePublisherMembers < ActiveRecord::Migration
  def change
    create_table :publisher_members do |t|
      t.integer :publisher_id, index: true
      t.integer :user_id, index: true
      t.boolean :owner, default: false

      t.timestamps null: false
    end
  end
end
