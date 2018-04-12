class CreateEgnyteFolders < ActiveRecord::Migration
  def change
    create_table :egnyte_folders do |t|
      t.references :subject, polymorphic: true

      t.string :uuid
      t.string :path

      t.timestamps null: false
    end

    add_index :egnyte_folders, [:subject_type, :subject_id], unique: true
  end
end
