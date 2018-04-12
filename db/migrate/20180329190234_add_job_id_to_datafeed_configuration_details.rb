class AddJobIdToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    unless column_exists? :datafeed_configuration_details, :job_id
      add_column :datafeed_configuration_details, :job_id, :string
    end
  end
end
