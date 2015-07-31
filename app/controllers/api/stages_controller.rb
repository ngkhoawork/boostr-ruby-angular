class Api::StagesController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.stages.order(:position)
  end
end
