class UserMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, subject, deal)
    @deal = deal
    mail(to: recipients, subject: subject)
  end

  def stage_changed_email(recipients, subject, deal_id)
    @deal = Deal.find(deal_id)
    mail(to: recipients, subject: subject)
  end
end
