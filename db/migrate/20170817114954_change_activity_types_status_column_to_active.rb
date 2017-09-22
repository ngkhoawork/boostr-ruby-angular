class ChangeActivityTypesStatusColumnToActive < ActiveRecord::Migration
  def change
    rename_column :activity_types, :status, :active
  end
end
