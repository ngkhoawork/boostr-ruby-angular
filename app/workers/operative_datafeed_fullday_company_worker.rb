class OperativeDatafeedFulldayCompanyWorker < BaseWorker
  include Sidekiq::Status::Worker

  def perform(id)
    return if api_config(id).blank?

    Operative::DatafeedService.new(api_config, Date.today).perform

    send_status_notification
  end

  def api_config(id=0)
    @api_config ||= OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(switched_on: true)
      .where(datafeed_configuration_details: { run_fullday: true })
      .find_by(id: id)
  end

  def expiration
    @expiration ||= 60 * 60 * 4 # 4 hours
  end

  def datafeed_status_notification
    api_config.company.notifications.find_by_name(Notification::DATAFEED_STATUS)
  end

  def send_status_notification
    recipients = datafeed_status_notification.recipients_arr

    UserMailer.datafeed_finished(recipients).deliver_now
  end
end
