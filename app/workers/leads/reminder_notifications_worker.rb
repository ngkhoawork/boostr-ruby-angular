class Leads::ReminderNotificationsWorker < BaseWorker
  def perform
    Lead.new_records.reassigned
  end
end
