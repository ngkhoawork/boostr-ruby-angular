class AddIntradayToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    unless column_exists? :datafeed_configuration_details, :run_intraday
      add_column :datafeed_configuration_details, :run_intraday, :boolean, default: false, null: false
    end

    unless column_exists? :datafeed_configuration_details, :run_fullday
      add_column :datafeed_configuration_details, :run_fullday, :boolean, default: false, null: false
    end

    unless column_exists? :datafeed_configuration_details, :company_name
      add_column :datafeed_configuration_details, :company_name, :string, default: '', null: false
    end
  end
end
