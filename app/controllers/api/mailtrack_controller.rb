class Api::MailtrackController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def open_mail
    decode_pixel = Base64.decode64(params[:pixel])
    params = pixel_to_params decode_pixel

    if EmailThread.find_by_email_thread_id(params[:email_open][:thread_id])
      EmailOpen.create(params[:email_open])
    end

    render nothing: true
  end

  def create_thread
    # TODO need add current user id when auth will be implemented
    email_thread = EmailThread.create(email_thread_id: params[:thread_id])

    if email_thread.save
      render json: email_thread, status: :created
    else
      render json: { errors: email_thread.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def pixel_to_params decoded_pixel
    { email_open: Rack::Utils.parse_nested_query(decoded_pixel).symbolize_keys }
  end
end