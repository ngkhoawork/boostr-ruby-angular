class AddCreateObjectsToSspCredentials < ActiveRecord::Migration
  def change
    add_column :ssp_credentials, :create_objects, :boolean
  end
end
