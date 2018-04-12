class AddEnableNetForecastingToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :enable_net_forecasting, :boolean, default: false
  end
end
