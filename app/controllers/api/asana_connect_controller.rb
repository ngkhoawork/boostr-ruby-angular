class Api::AsanaConnectController < ApplicationController
  respond_to :json

  def index
    render json: { url: AsanaConnect.url(current_user.id) }
  end

  def callback
    AsanaConnect.callback(asana_connect_params)
    redirect_to '/settings/api_configurations'
  end

  private

  def asana_connect_params
    params.permit(:code, :state)
  end
end
