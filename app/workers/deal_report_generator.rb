class DealReportGenerator < BaseWorker
  def perform
    active_notifications = Notification.active_deal_notifications
    active_notifications.each do |notification|
      recipients = notification.recipients_arr
      next if recipients.blank?
      ReportsMailer.deals_daily_mail(recipients).deliver_now
    end
  end
end