class Api::DealAssetsController < ApplicationController
  respond_to :json

  def index
    render json: deal.assets
  end

  def create
    asset = deal.assets.new(asset_params)

    if asset.save
      render json: asset, status: :created
    else
      render json: { errors: asset.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def asset_params
    params.require(:asset).permit(:asset_file_name, :asset_file_size, :asset_content_type, :original_file_name)
  end

  def deal
    @deal ||= company.deals.find(params[:deal_id])
  end

  def company
    @company ||= current_user.company
  end
end
