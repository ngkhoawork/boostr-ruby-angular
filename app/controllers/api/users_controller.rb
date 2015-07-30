class Api::UsersController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.users
  end
end
