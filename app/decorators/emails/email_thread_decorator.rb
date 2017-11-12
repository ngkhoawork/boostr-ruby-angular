class Emails::EmailThreadDecorator
  def initialize(params)
    @params = params
    @gmail_query = parse_gmail_query(params[:gmail_query_string])
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
      recipient: recipient
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
    Griddler::Email.new({to: @gmail_query[:to], from: @gmail_query[:from]})
  end

  def body
    @gmail_query[:body]
  end

  def subject
    @gmail_query[:subject]
  end

  def email_guid
    @params[:email_guid]
  end

  def thread_id
    @params[:thread_id]
  end

  def parse_gmail_query query
    params = {}
    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split('=', 2).collect{ |v| CGI::unescape(v) }
      if key && value
        unless key.empty? || value.empty?
          if params.has_key?(key)
            params[key].push(value)
          else
            key == 'to' ? params[key] = [value] : params[key] = value
          end
        end
      end
    end

    params.symbolize_keys
  end
end