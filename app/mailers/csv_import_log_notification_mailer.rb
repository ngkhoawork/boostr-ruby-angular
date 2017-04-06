class CsvImportLogNotificationMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'

  def send_email(recipients, csv_import_log_id)
    @import_log = CsvImportLog.find(csv_import_log_id)
    subject = "boostr IO Feed Errors"
    mail(to: recipients, subject: subject)
  end
end
