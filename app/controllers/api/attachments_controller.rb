class Api::AttachmentsController < ApplicationController
  respond_to :json

  def index
    render json: resource.assets
  end

  def update
    if asset.update_attributes(asset_params)
      render json: asset, status: :accepted
    else
      render json: { errors: asset.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    asset = resource.assets.new(asset_params)
    asset.created_by = current_user.id

    if asset.save
      render json: asset, status: :created
    else
      render json: { errors: asset.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    asset.destroy

    render nothing: true
  end

  private

  def asset
    resource.assets.find(params[:id])
  end

  def asset_params
    params
      .require(:asset)
      .permit(:asset_file_name, :asset_file_size, :asset_content_type, :original_file_name, :comment, :subtype)
  end

  def resource
    @_resource ||= detect_resource
  end

  def detect_resource
    type = params[:deal_id] ? 'deal' : 'publisher'

    case type
    when 'deal'
      company.deals.find(params[:deal_id])
    when 'publisher'
      company.publishers.find(params[:publisher_id])
    end
  end

  def company
    @_company ||= current_user.company
  end
end
