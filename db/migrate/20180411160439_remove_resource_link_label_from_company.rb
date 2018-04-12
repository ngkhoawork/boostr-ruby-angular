class RemoveResourceLinkLabelFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :resource_link_label
  end
end
