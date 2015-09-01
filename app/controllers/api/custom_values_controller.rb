class Api::CustomValuesController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.settings.to_json
  end

end