class AddSkipNotChangedToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    add_column :datafeed_configuration_details, :skip_not_changed, :boolean, default: false
  end
end
