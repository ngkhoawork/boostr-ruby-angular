class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.belongs_to :deal, index: true, foreign_key: true
      t.references :requester, references: :users, index: true
      t.references :assignee, references: :users, index: true
      t.integer :requestable_id
      t.string :requestable_type
      t.string :status
      t.text :description, default: ""
      t.text :resolution, default: ""
      t.date :due_date

      t.timestamps null: false
    end

    add_foreign_key :requests, :users, column: :requester_id
    add_foreign_key :requests, :users, column: :assignee_id
  end
end
