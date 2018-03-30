class OperativeDatafeedIntradayCompanyWorker < BaseWorker
  include Sidekiq::Status::Worker

  def perform(id)
    if api_config(id).present?
      Operative::DatafeedService.new(api_config(id), Date.today, intraday: true).perform
    end
  end

  def api_config(id)
    @api_config ||= OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(switched_on: true)
      .where(datafeed_configuration_details: { run_intraday: true })
      .find_by(id: id)
  end

  def expiration
    @expiration ||= 60 * 60 * 1 # 1 hour
  end
end
