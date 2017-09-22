class CreateDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    create_table :datafeed_configuration_details do |t|
      t.boolean :auto_close_deals, default: false
      t.references :api_configuration, index: true, foreign_key: true

      t.timestamps null: false
    end

    update_existing_datafeed_configurations
  end

  def update_existing_datafeed_configurations
    OperativeDatafeedConfiguration.find_each do |odc|
      odc.create_datafeed_configuration_details
    end
  end
end
