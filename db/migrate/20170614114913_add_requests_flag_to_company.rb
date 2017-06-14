class AddRequestsFlagToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :requests_enabled, :boolean, default: false
  end
end
