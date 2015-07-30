class CreateClientMember < ActiveRecord::Migration
  def change
    create_table :client_members do |t|
      t.belongs_to :client, index: true
      t.belongs_to :user, index: true
      t.integer :share
      t.string :role

      t.timestamps null: false
    end
  end
end
