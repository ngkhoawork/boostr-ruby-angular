class CsvImportLog < ActiveRecord::Base
  belongs_to :company, required: true
  serialize :error_messages, JSON

  after_create :send_notification

  default_scope { order(created_at: :desc) }

  scope :for_company, -> (id) { where(company_id: id) }
  scope :by_source,   -> (source) { where(source: source) if source.present? }

  def count_processed
    self.rows_processed += 1
  end

  def count_imported
    self.rows_imported += 1
  end

  def count_failed
    self.rows_failed += 1
  end

  def count_skipped
    self.rows_skipped += 1
  end

  def log_error(error)
    self.error_messages ||= []
    self.error_messages << { row: rows_processed, message: error }
  end

  def set_file_source(path)
    self.file_source = File.basename(path)
  end

  def is_error?
    self.rows_failed > 0
  end

  private

  def send_notification
    if !(self.source == 'ui') && is_error? && error_log_recipients.any?
      CsvImportLogNotificationMailer.send_email(error_log_recipients, id).deliver_later(queue: "default")
    end
  end

  def error_log_recipients
    return [] unless active_company_notifications.any?
    active_company_notifications.first.recipients_arr
  end

  def active_company_notifications
    Notification.active_error_log_notifications.where(company: company)
  end
end
