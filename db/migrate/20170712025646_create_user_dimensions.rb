class CreateUserDimensions < ActiveRecord::Migration
  def change
    create_table :user_dimensions do |t|
      t.belongs_to :team, index: true, foreign_key: true
      t.belongs_to :company, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :user_dimensions, [:team_id, :id]
  end
end
