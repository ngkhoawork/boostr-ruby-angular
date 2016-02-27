class UserMailer < ApplicationMailer
  default from: 'Boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, subject, deal)
    @deal = deal
    mail(to: recipients, subject: subject)
  end
end
