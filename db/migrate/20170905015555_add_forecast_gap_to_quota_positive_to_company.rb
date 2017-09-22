class AddForecastGapToQuotaPositiveToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :forecast_gap_to_quota_positive, :boolean, default: true
  end
end
