class Emails::EmailThreadDecorator
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def collect
    {
      email_guid: email_guid,
      thread_id: thread_id,
      subject: subject,
      body: body,
      sender: attendees.from[:name],
      from: attendees.from[:email],
      recipient_email: to,
      recipient: recipient,
      user: @current_user
    }
  end

  private

  def recipient
    attendees.to.map{ |to| to[:name] }.join(', ')
  end

  def to
    attendees.to.map{ |to| to[:email] }.join(', ')
  end

  def attendees
    Griddler::Email.new({
      to: gmail_query_string[:to],
      from: URI.unescape(gmail_query_string[:from])
    })
  end

  def body
    gmail_query_string[:body]
  end

  def subject
    gmail_query_string[:subject]
  end

  def email_guid
    @params[:email_guid]
  end

  def thread_id
    @params[:thread_id]
  end

  def gmail_query_string
    @params[:gmail_query_string]
  end
end
