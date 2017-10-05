class Api::MailtrackController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def open_mail
    decode_pixel = Base64.decode64(params[:pixel])
    params = pixel_to_params decode_pixel

    if EmailThread.find_by_email_guid(params[:email_open][:guid])
      params[:email_open][:ip] = request.remote_ip
      params[:email_open][:opened_at] = Time.now
      params[:email_open][:location] = get_location_from_ip request.remote_ip
      params[:email_open][:device] = device_info request.user_agent

      EmailOpen.create(params[:email_open])
    end

    set_cache_headers
    send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
  end

  private

  def pixel_to_params decoded_pixel
    { email_open: Rack::Utils.parse_nested_query(decoded_pixel).symbolize_keys }
  end

  def get_location_from_ip remote_ip
    geo_ip = Geocoder.search(remote_ip).first.data.symbolize_keys

    geo_ip[:city].present? ? geo_ip[:city] : geo_ip[:country_name]
  end

  def device_info user_agent
    parse_ua = UserAgentParser.parse user_agent

    device = parse_ua.device.family == 'Other' ? parse_ua.os.to_s : parse_ua.device.family

    [device, parse_ua.family].join(", ")
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
  end
end