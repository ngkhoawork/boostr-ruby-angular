class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :company_id
      t.integer :created_by
      t.integer :updated_by
      t.string :website

      t.timestamps null: false
    end
  end
end
