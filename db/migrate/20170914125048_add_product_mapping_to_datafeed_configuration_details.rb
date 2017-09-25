class AddProductMappingToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    add_column :datafeed_configuration_details, :product_mapping, :integer, default: 0, null: false
  end
end
