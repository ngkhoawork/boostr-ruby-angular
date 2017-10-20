class AddExcludeChildLineItemsToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    add_column :datafeed_configuration_details, :exclude_child_line_items, :boolean
  end
end
