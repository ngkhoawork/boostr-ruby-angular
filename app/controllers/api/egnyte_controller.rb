class Api::EgnyteController < ApplicationController
  respond_to :json

  def index
    egnyte = EgnyteService.new()

    render json: {egnyteTokenUrl: egnyte.get_egnyte_code}
  end

  def egnyte_oauth_callback
    # TODO
    redirect_to "https://192.168.2.127:3000/settings/egnyte"
  end


end