class IntegrationLog < ActiveRecord::Base
  belongs_to :deal
  belongs_to :company

  after_create :send_notification

  private

  def send_notification
    if is_error? && error_log_recipients.any?
      ErrorLogNotificationMailer.error_log_notification_email(error_log_recipients, id).deliver_later(queue: "default")
    end
  end

  def error_log_recipients
    return [] unless active_company_notifications.any?
    active_company_notifications.first.recipients_arr
  end

  def active_company_notifications
    Notification.active_error_log_notifications.where(company: company)
  end
end
