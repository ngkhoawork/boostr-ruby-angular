namespace :company_notifications do
  desc "Create notifications for api logger"
  task create_error_log_notitication: :environment do
    Notification.create(company_id: 22, active: true, name: 'Error Log')
  end
end