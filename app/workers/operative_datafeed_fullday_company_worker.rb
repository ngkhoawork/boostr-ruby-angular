class OperativeDatafeedFulldayCompanyWorker < BaseWorker
  include Sidekiq::Status::Worker

  def perform(id)
    return if api_config(id).blank?

    Operative::DatafeedService.new(api_config(id), Date.today).perform
  end

  def api_config(id)
    @api_config ||= OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(switched_on: true)
      .where(datafeed_configuration_details: { run_fullday: true })
      .find_by(id: id)
  end

  def expiration
    @expiration ||= 60 * 60 * 4 # 4 hours
  end
end
