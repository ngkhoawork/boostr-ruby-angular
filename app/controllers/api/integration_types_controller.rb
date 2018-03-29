class Api::IntegrationTypesController < ApplicationController
  respond_to :json

  def index
    render json: Integration.get_types(current_user)
  end
end
