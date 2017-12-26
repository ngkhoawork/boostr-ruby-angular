class StoppedPmpDetectWorker < BaseWorker
  def perform
    today = DateTime.now.beginning_of_day.to_date
    mails = {}
    Pmp.all.each do |pmp|
      if pmp.end_date >= today && pmp.pmp_item_daily_actuals.where(date: today).empty?
        notification = pmp.company.notifications.find_by_name(Notification::PMP_STOPPED_RUNNING)
        if notification.present?  
          notification.recipients_arr.each do |recipient|
            mails[recipient] ||= []
            mails[recipient] << pmp
          end
        end
      end
    end

    mails.each do |recipient, pmps|
      UserMailer.stopped_pmp_email([recipient], pmps).deliver_now
    end
  end
end