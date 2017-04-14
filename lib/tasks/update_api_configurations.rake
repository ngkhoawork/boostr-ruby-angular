namespace :api_configurations do
  task update_integration_type: :environment do
    sql = "UPDATE api_configurations SET integration_type = 'OperativeApiConfiguration', integration_provider = 'operative' where integration_type = 'operative';
          UPDATE api_configurations SET integration_type = 'OperativeDatafeedConfiguration', integration_provider = 'Operative Datafeed' where integration_type = 'Operative Datafeed'"
    ActiveRecord::Base.connection.execute(sql)
  end
end