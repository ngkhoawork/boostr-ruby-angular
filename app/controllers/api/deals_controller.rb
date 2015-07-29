class Api::DealsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.deals.includes(:advertiser, :agency)
  end

  def create
    deal = current_user.company.deals.new(deal_params)
    if deal.save
      render json: deal, status: :created
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def deal_params
    params.require(:deal).permit(:name, :stage, :budget, :start_date, :end_date,
    :advertiser_id, :agency_id)
  end
end
