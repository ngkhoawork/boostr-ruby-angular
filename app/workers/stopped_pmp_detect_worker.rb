class StoppedPmpDetectWorker < BaseWorker
  def perform
    mails = {}
    Pmp.stopped.each do |pmp|
      notification = pmp.company.notifications.find_by_name(Notification::PMP_STOPPED_RUNNING)
      if notification.present?  
        notification.recipients_arr.each do |recipient|
          mails[recipient] ||= []
          mails[recipient] << pmp
        end
      end
    end

    mails.each do |recipient, pmps|
      UserMailer.stopped_pmp_email([recipient], pmps).deliver_now
    end
  end
end