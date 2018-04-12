class AddResourceLinkFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :resource_link, :string
    add_column :companies, :resource_link_label, :string
  end
end
