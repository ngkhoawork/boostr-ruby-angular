class UserMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, subject, deal)
    @deal = deal
    mail(to: recipients, subject: subject)
  end
end
