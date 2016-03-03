class Api::RevenueController < ApplicationController
  respond_to :json

  def index
    render json: revenues
  end

  def create
    csv_file = IO.read(params[:file].tempfile.path)
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

  def revenues
    if current_user.leader?
      if params[:filter] == 'upside'
        current_user.company.revenues.where("revenues.balance > 0")
      elsif params[:filter] == 'risk'
        current_user.company.revenues.where("revenues.balance < 0")
      else
        current_user.company.revenues
      end
    else
      if params[:filter] == 'upside'
        current_user.company.revenues.where(user_id: current_user.id).where("revenues.balance > 0")
      elsif params[:filter] == 'risk'
        current_user.company.revenues.where(user_id: current_user.id).where("revenues.balance < 0")
      else
        current_user.company.revenues.where(user_id: current_user.id)
      end
    end
  end
end
