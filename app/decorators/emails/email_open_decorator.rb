class Emails::EmailOpenDecorator
  def initialize(params, request)
    @params = params
    @request = request
  end

  def collect
    {
      email: email,
      ip: ip,
      opened_at: opened_at,
      location: location,
      device: device,
      is_gmail: is_gmail,
      guid: guid
    }
  end

  private

  def guid
    @params[:guid]
  end

  def ip
    @request.remote_ip
  end

  def opened_at
    Time.now
  end

  def location
    geo_ip = Geocoder.search(@request.remote_ip).first.data.symbolize_keys

    geo_ip[:city].present? ? geo_ip[:city] : geo_ip[:country_name]
  end

  def email
    @params[:email]
  end

  def device
    parse_ua = UserAgentParser.parse @request.user_agent

    device = parse_ua.device.family == 'Other' ? parse_ua.os.to_s : parse_ua.device.family
    [device, parse_ua.family].join(", ")
  end

  def is_gmail
    Resolv.new.getname(@request.remote_ip).include?('google.com') rescue false
  end
end