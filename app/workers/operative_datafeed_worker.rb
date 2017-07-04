class OperativeDatafeedWorker < BaseWorker
  def perform
    datafeed_configs = OperativeDatafeedConfiguration.all
    datafeed_configs.each do |api_config|
      Operative::DatafeedService.new(api_config, Date.today - 1.day).perform
    end
  end
end
