class EgnyteMailer < ApplicationMailer
  default from: '<admin@boostr.com>'

  def company_connection(recipient, auth_link)
    @auth_link = auth_link

    mail(to: recipient, subject: 'Connect Egnyte integration')
  end
end
