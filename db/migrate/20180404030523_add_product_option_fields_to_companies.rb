class AddProductOptionFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :product_option1_enabled, :boolean, default: false
    add_column :companies, :product_option2_enabled, :boolean, default: false
  end
end
