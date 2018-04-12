class Api::SlackConnectController < ApplicationController

  def auth
    render json: { url: connection_link }
  end

  def callback
    SlackConnector.callback(connector_params)

    redirect_to '/settings/api_configurations'
  end

  private

  def connection_link
    SlackConnector.url(current_user.company_id)
  end

  def connector_params
    params.permit(:code, :state, :error)
  end
end
