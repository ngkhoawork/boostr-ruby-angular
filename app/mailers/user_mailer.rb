class UserMailer < ApplicationMailer
  default from: 'Boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, member, deal, advertiser)
    @recipients = recipients
    @member = member
    @deal = deal
    @advertiser = advertiser
    mail(to: @recipients, subject: 'Congratulation! A deal was just won!')
  end
end
