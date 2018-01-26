class Leads::ReassignmentNotificationsWorker < BaseWorker
  def perform
    send_notifications
  end

  private

  def send_notifications
    ecords.each do |record|
      LeadsMailer.reassignment_notification(record).deliver_now

      record.assign_reviewer

      LeadsMailer.new_leads_assignment(record).deliver_now

      record.create_notification_reminders
    end
  end

  def records
    Lead.new_records
        .notification_reminders_by_dates(Lead::REASSIGNMENT, Time.now, Time.now + 1.hour)
  end
end
