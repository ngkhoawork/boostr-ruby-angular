class StoppedPmpDetectWorker < BaseWorker
  def perform
    mails = {}
    date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date - 1.day
    pmp_items = PmpItem.joins("LEFT JOIN 
      (
        SELECT pmp_item_id, MAX(date) AS last_date 
        FROM pmp_item_daily_actuals 
        GROUP BY pmp_item_id
      ) AS actuals
      ON actuals.pmp_item_id=pmp_items.id")
    .joins("LEFT JOIN pmps ON pmps.id=pmp_items.pmp_id")
    .where("(actuals.last_date IS NULL OR actuals.last_date < ?) AND 
      pmps.end_date >= ? AND 
      pmps.start_date <= ?", date, date, date)

    pmp_items.each do |pmp_item|
      pmp_item.update(is_stopped: true, stopped_at: pmp_item.daily_actual_end_date + 1.day) unless pmp_item.is_stopped
      notification = pmp_item.pmp.company.notifications.find_by_name(Notification::PMP_STOPPED_RUNNING)
      if notification.present?  
        notification.recipients_arr.each do |recipient|
          mails[recipient] ||= []
          mails[recipient] << pmp_item
        end
      end
    end

    mails.each do |recipient, pmp_items|
      UserMailer.stopped_pmp_email([recipient], pmp_items).deliver_later(queue: 'default')
    end
  end
end