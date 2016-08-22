class AddOriginalFileNameToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :original_file_name, :string
  end
end
