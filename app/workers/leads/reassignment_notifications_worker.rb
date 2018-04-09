class Leads::ReassignmentNotificationsWorker < BaseWorker
  def perform
    send_notifications
  end

  private

  def send_notifications
    records.each do |record|
      LeadsMailer.reassignment_notification(record).deliver_now

      record.notification_reminders.by_type(Lead::REASSIGNMENT).delete_all

      binding.pry
      record.assign_reviewer(true)

      LeadsMailer.new_leads_assignment(record).deliver_now

      record.create_notification_reminders
    end
  end

  def records
    # Lead.find(17).notification_reminders.last.update(sending_time: Time.now.utc + 20.minutes)
    Lead.new_records
        .notification_reminders_by_dates(Lead::REASSIGNMENT, Time.now.utc, Time.now.utc + 1.hour)
  end
end
