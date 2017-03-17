class OperativeDatafeedWorker < BaseWorker
  def perform
    datafeed_configs = ApiConfiguration.where(integration_type: "Operative Datafeed")
    datafeed_configs.each do |api_config|
      Operative::DatafeedService.new(api_config).perform
    end
  end
end
