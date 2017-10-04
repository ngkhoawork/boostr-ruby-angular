class Api::MailtrackController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def open_mail
    decode_pixel = Base64.decode64(params[:pixel])
    params = pixel_to_params decode_pixel

    if EmailThread.find_by_email_guid(params[:email_open][:guid])
      params[:email_open][:opened_at] = Time.now
      EmailOpen.create(params[:email_open])
    end

    send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
  end

  private

  def pixel_to_params decoded_pixel
    { email_open: Rack::Utils.parse_nested_query(decoded_pixel).symbolize_keys }
  end
end