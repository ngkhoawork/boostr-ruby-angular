namespace :api_configurations do
  task update_asana_api_configs: :environment do
    AsanaConnectConfiguration.find_each do |acc|
      acc.update(
        asana_connect_details_attributes: {
          project_name: acc.network_code,
          workspace_name: acc.network_code
        },
        network_code: nil
      )
    end
  end
end
