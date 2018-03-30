class OperativeDatafeedFulldayWorker < BaseWorker
  def perform
    datafeed_configs.each do |datafeed_config|
      datafeed_config.start_job(job_type: 'fullday')
    end
  end

  def datafeed_configs
    OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(switched_on: true)
      .where(datafeed_configuration_details: { run_fullday: true })
  end
end
