class AddProductOptionsEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :product_options_enabled, :boolean, default: false
    add_column :companies, :product_option1_field, :string, default: 'Option1'
    add_column :companies, :product_option2_field, :string, default: 'Option2'
  end
end
