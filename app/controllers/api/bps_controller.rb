class Api::BpsController < ApplicationController
  respond_to :json

  def index
    render json: company.bps.map{ |bp| bp.as_json}
  end

  def create
    bp = company.bps.new(bp_params)
    if bp.save
      render json: bp.as_json, status: :created
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    bp = company.bps.find(params[:id])
    if bp.update_attributes(bp_params)
      render json: bp.as_json
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def bp_params
    params.require(:bp).permit(:name, :time_period_id, :due_date)
  end

  def company
    current_user.company
  end

  def bps
    company.bps
  end
end
