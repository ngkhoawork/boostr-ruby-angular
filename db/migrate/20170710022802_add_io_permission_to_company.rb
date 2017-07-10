class AddIoPermissionToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :io_permission, :jsonb, null: false, default: '{"0": true, "1": true, "2": true, "3": true, "4": true, "5": true, "6": true, "7": true}'
    add_index  :companies, :io_permission, using: :gin
  end
end
