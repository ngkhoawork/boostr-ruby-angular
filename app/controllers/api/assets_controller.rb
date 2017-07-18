class Api::AssetsController < ApplicationController
  include CleanPagination
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
    max_per_page = 50
    paginate company_unmapped_assets.count, max_per_page do |limit, offset|
      render json: company_unmapped_assets
                    .select(:id, :original_file_name, :asset_file_name)
                    .limit(limit)
                    .offset(offset)
    end
  end

  private

  def company_unmapped_assets
    current_user.company.assets.unmapped
  end

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
