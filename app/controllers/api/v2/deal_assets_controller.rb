class Api::V2::DealAssetsController < ApiController
  respond_to :json

  def index
    render json: deal.assets
  end

  def update
    if asset.update_attributes(asset_params)
      render json: asset, status: :accepted
    else
      render json: { errors: asset.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    asset = deal.assets.new(asset_params)
    asset.created_by = current_user.id

    if asset.save
      render json: asset, status: :created
    else
      render json: { errors: asset.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    asset.delete_from_s3
    asset.destroy
    render nothing: true
  end

  private

  def asset
    deal.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:asset_file_name, :asset_file_size, :asset_content_type, :original_file_name, :comment, :subtype)
  end

  def deal
    @deal ||= company.deals.find(params[:deal_id])
  end

  def company
    @company ||= current_user.company
  end
end
