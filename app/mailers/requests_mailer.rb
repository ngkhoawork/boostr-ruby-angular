class RequestsMailer < ApplicationMailer
  default from: 'boostr <noreply@boostrcrm.com>'

  def new_request(recipients, request_id)
    begin
      @request = Request.find(request_id)
      subject = "You Have a New #{@request.request_type} Request"
      mail(to: recipients&.uniq, subject: subject)
    rescue ActiveRecord::RecordNotFound
    end
  end

  def update_request(recipients, request_id)
    begin
      @request = Request.find(request_id)
      subject = "#{@request.request_type} Request for Deal #{@request.deal.name}"
      mail(to: recipients&.uniq, subject: subject)
    rescue ActiveRecord::RecordNotFound
    end
  end
end
