class Api::AssetsController < ApplicationController
  respond_to :json

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'AssetCsv',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    elsif params[:assets].present?
      assets_params.each do |file|
        asset = current_user.company.assets.new single_asset(file)
        asset.created_by = current_user.id
        asset.save
      end

      head :ok
    elsif params[:asset].present?
      asset = current_user.company.assets.new(asset_params)
      asset.created_by = current_user.id

      if asset.save
        render json: asset, status: :created
      else
        render json: { errors: asset.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def metadata
    render json: current_user.company.assets.unmapped.select(:id, :original_file_name, :asset_file_name)
  end

  private

  def asset_params
    single_asset params.require(:asset)
  end

  def assets_params
    params.require(:assets)
  end

  def single_asset(asset)
    asset.permit(:asset_file_name, :asset_file_size, :asset_content_type, :original_file_name)
  end
end
