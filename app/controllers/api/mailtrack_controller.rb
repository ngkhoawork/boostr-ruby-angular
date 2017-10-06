class Api::MailtrackController < ApplicationController
  PIXEL_IMG = "R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==".freeze
  skip_before_filter :authenticate_user!
  respond_to :json

  def open_mail
    decode_pixel = Base64.decode64(params[:pixel])
    params = Rack::Utils.parse_nested_query(decode_pixel).symbolize_keys

    if EmailThread.exists?(email_guid: params[:guid])
      meta = {
        ip: request.remote_ip,
        opened_at: Time.now,
        location: get_location_from_ip(request.remote_ip),
        device: device_info(request.user_agent),
        is_gmail: detect_google_proxy(request.remote_ip)
      }

      params.merge!(meta)

      EmailOpen.create(params)
    end

    set_cache_headers
    send_data Base64.decode64(PIXEL_IMG), type: 'image/gif', disposition: 'inline'
  end

  private

  def detect_google_proxy remote_ip
    Resolv.new.getname(remote_ip).include?('google.com')
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