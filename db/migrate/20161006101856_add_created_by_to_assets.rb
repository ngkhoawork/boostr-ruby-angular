class AddCreatedByToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :created_by, :integer
  end
end
