class CreateInitiatives < ActiveRecord::Migration
  def change
    create_table :initiatives do |t|
      t.string :name
      t.integer :goal
      t.string :status
      t.integer :company_id

      t.timestamps null: false
    end
  end
end
