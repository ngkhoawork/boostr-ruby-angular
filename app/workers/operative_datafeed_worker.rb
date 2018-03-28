class OperativeDatafeedFulldayWorker < BaseWorker
  def perform
    datafeed_configs.each do |api_config|
      Operative::DatafeedService.new(api_config, Date.today - 1.day).perform
    end
  end

  def datafeed_configs
    OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(switched_on: true)
      .where(datafeed_configuration_details: { run_fullday: true })
  end
end
