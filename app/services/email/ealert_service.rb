class Email::EalertService
  def initialize(deal)
    @deal = deal
    @ealert = deal.company.ealerts.first
  end

  def perform
    send_ealert
  end

  private

  attr_reader :deal, :ealert

  def cancel_scheduled_jobs
    if ealert
      scheduler = Sidekiq::ScheduledSet.new
      scheduler.each do |s|
        args = s.args[0] rescue nil
        if args && args['job_class'] && args['job_class'].to_s == 'ActionMailer::DeliveryJob'
          arguments = args[:arguments]
          if arguments && arguments.length > 5 && arguments[0].to_s == 'UserMailer' && arguments[1].to_s == 'ealert_email' && arguments[4] == ealert.id && arguments[5] == deal.id
            s.delete
          end
        end
      end
    end
  end
  def send_ealert
    if ealert
      delay = ealert.delay && ealert.delay > 0 ? ealert.delay : 0
      ealert_stage = ealert.ealert_stages.find_by(stage_id: deal.stage_id)
      if ealert_stage && ealert_stage.enabled == true
        recipients = []
        if ealert.same_all_stages == true
          recipients = ealert.recipients.split(',').map(&:strip) if ealert.recipients
        else
          recipients = ealert_stage.recipients.split(',').map(&:strip) if ealert_stage.recipients
        end
        deal_members = deal.deal_members.order("share desc")
        highest_member = nil
        if deal_members.count > 0
          highest_member = deal_members[0].user_id
        end
        cancel_scheduled_jobs
        UserMailer.ealert_email(recipients, ealert.id, deal.id, '', highest_member).deliver_later(wait: delay.minutes, queue: "default") if recipients.length > 0
      end
    end
  end
end