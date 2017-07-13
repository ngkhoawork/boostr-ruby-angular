class CreateStageDimensions < ActiveRecord::Migration
  def change
    create_table :stage_dimensions do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :name
      t.integer :probability
      t.boolean :open

      t.timestamps null: false
    end
  end
end
