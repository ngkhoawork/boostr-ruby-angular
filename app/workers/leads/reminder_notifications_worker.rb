class Leads::ReminderNotificationsWorker < BaseWorker
  def perform
    send_notifications
  end

  private

  def send_notifications
    records.each do |record|
      LeadsMailer.reminder_notification(record).deliver_now

      record.notification_reminders.by_type(Lead::REMINDER).delete_all
    end
  end

  def records
    Lead.new_records
        .notification_reminders_by_dates(Lead::REMINDER, Time.now, Time.now + 1.hour)
  end
end
