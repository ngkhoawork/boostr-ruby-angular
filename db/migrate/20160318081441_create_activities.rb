class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :contact_id
      t.integer :deal_id
      t.integer :client_id
      t.string :activity_type
      t.datetime :happened_at
      t.integer :updated_by
      t.integer :created_by
      t.text :comment

      t.timestamps null: false
    end
  end
end
