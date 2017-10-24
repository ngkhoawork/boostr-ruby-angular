class Api::MailtrackController < ApplicationController
  PIXEL_IMG = "R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==".freeze
  skip_before_filter :authenticate_user!
  respond_to :json

  def open_mail
    decode_pixel = Base64.decode64(params[:pixel])
    params = Rack::Utils.parse_nested_query(decode_pixel).symbolize_keys

    if EmailThread.exists?(email_guid: params[:guid])
      decorated_data = decorated_email_opens(params)

      EmailOpen.create(decorated_data)
    end

    set_cache_headers
    send_data Base64.decode64(PIXEL_IMG), type: 'image/gif', disposition: 'inline'
  end

  private

  def decorated_email_opens(params)
    Emails::EmailOpenDecorator.new(params, request).collect
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
  end
end