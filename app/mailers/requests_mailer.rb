class RequestsMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'

  def send_email(recipients, request_id)
    @request = Request.find(request_id)
    subject = "You Have a New #{@request.request_type} Request"
    mail(to: recipients, subject: subject)
  end
end
