module Mailer
  module NoMatchIo
    def notify(temp_io_ids, company_id)
      company = Company.find(company_id)
      return unless company.present?
      @temp_ios = TempIo.find(temp_io_ids)
      return unless @temp_ios.present?
      @notification = company.notifications.active.find_by(event_type: Notification::TYPES['no_match_io'])
      return unless @notification.present?
      return if @notification.recipients.blank?
      mail(to: @notification.recipients, subject: @notification.subject)
    end
  end
end
