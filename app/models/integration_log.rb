class IntegrationLog < ActiveRecord::Base
  belongs_to :deal
  belongs_to :company

  after_create :send_notification

  def send_notification
    recipients = if active_company_notifications.any?
                   active_company_notifications.first.recipients_arr
                 else
                   []
                 end

    if is_error? && recipients.any?
      ErrorLogNotificationMailer.error_log_notification_email(recipients, id).deliver_later(queue: "default")
    end
  end

  private

  def active_company_notifications
    @notifications ||= Notification.active_error_log_notifications.where(company: company)
  end


end
