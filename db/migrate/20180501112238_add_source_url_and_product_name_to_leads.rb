class AddSourceUrlAndProductNameToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :source_url, :string
    add_column :leads, :product_name, :string
  end
end
