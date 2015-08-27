class Api::DealsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.deals.for_client(params[:client_id]).includes(:advertiser, :stage)
  end

  def show
    deal
  end

  def create
    deal = current_user.company.deals.new(deal_params)
    deal.created_by = current_user.id
    if deal.save
      render json: deal, status: :created
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if deal.update_attributes(deal_params)
      render deal
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal.destroy
    render nothing: true
  end

  private

  def deal_params
    params.require(:deal).permit(:name, :stage_id, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :deal_type, :source_type, :next_steps)
  end

  def deal
    @deal ||= current_user.company.deals.find(params[:id])
  end
end
