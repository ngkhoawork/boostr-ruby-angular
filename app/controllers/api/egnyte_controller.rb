class Api::EgnyteController < ApplicationController
  respond_to :json

  def index
    egnyte = EgnyteService.new(company, request)

    render json: {egnyteTokenUrl: egnyte.get_egnyte_code}
  end

  def egnyte_oauth_callback
    redirect_to "#{request.base_url}/settings/egnyte"
  end

  def save_token
    if company.update(egnyte_access_token: filter_params[:access_token], egnyte_connected: true)
      render json: { status: "Token Updated!", data: company.as_json }
    else
      render json: { status: "Error!" }
    end
  end

  def update_egnyte_settings
    if filter_params[:action_type]
      setup_token
    else
      egnyte_connect
    end
  end

  private

  def setup_token
    if company.update(egnyte_access_token: nil)
      render json: { status: "Disconnected!", data: company.as_json }
    else
      render json: { status: "Error!" }
    end
  end

  def egnyte_connect
    if company.update(egnyte_connected: filter_params[:egnyte_connected])
      render json: { status: "Egnyte updated!", data: company.as_json }
    else
      render json: { status: "Error!" }
    end
  end

  def company
    current_user.company
  end

  def filter_params
    params.permit(:access_token, :egnyte_connected, :action_type)
  end

end