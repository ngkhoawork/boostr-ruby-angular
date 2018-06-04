class AddNotificationsForCompanies < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        company_ids = Company.includes(:notifications).map { |d|
          d.id unless d.notifications.where(event_type:1).present?
        }.compact
        message = "You have one or more IOs imported that couldn`t be matched. Please go to https://app.boostr.com/revenue and click the No Match IO tab to resolve these IOs."
        event_type = Notification::TYPES['no_match_io']
        date = Time.now
        company_ids.each do |company_id|
          execute <<-SQL
            INSERT INTO notifications (company_id, name, subject, message, active, event_type, created_at, updated_at)
            VALUES ('#{company_id}', 'No-Match IOs', 'New No-Match IO Records', '#{message}', '1', '#{event_type}','#{date}','#{date}' )
          SQL
        end
      end
    end
  end
end
