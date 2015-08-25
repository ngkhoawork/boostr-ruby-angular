class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :company_id
      t.belongs_to :parent, index: true
      t.timestamps null: false
    end
  end
end
