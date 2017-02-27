class ErrorLogNotificationMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'

  def error_log_notification_email(recipients, integration_log_id)
    @integration_log = IntegrationLog.find(integration_log_id)
    subject = "boostr Integration Error #{@integration_log.api_provider} - #{@integration_log.object_name}"
    mail(to: recipients, subject: subject)
  end
end