class Api::RevenueController < ApplicationController

  def index
    render json: current_user.company.revenues
  end

end
