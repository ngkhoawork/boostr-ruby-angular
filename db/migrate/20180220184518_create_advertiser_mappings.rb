class CreateAdvertiserMappings < ActiveRecord::Migration
  def change
    create_table :ssp_advertisers do |t|
      t.string :name, null: false
      t.integer :company_id, index: true, foreign_key: true
      t.integer :ssp_id, index: true, foreign_key: true
      t.integer :created_by, index: true, foreign_key: true
      t.integer :updated_by, index: true, foreign_key: true
      t.timestamps
    end
  end
end
