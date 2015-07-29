class Api::RevenueController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.revenues
  end

  def create
    csv_file = IO.read(params[:file].tempfile.path)
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

end
