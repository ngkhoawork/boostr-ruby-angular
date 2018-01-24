class Leads::ReassignmentNotificationsWorker < BaseWorker
  def perform
    Lead.new_records.reassigned
  end
end
