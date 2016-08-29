class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.string :asset_file_name
      t.string :asset_file_size
      t.string :asset_content_type
      t.timestamps null: false
    end
  end
end
