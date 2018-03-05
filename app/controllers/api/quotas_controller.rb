class Api::QuotasController < ApplicationController
  respond_to :json

  def index
    render json: quotas
  end

  def create
    quota = current_user.company.quotas.build(quota_params)

    if quota.save
      render json: quota, status: :created
    else
      render json: { errors: quota.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if quota.update_attributes(quota_params)
      render json: quota, status: :accepted
    else
      render json: { errors: quota.errors.messages }, status: :unprocessable_entity
    end
  end

  def import
    csv_import_worker_perform

    render json: { message: import_message }, status: :ok
  end

  private

  def time_period
    @time_period = current_user.company.time_periods.find(params[:time_period_id])
  end

  def quotas
    if params[:time_period_id].present?
      current_user.company.quotas.where(time_period_id: params[:time_period_id])
    else
      current_user.company.quotas
    end
  end

  def quota
    @quota ||= current_user.company.quotas.find(params[:id])
  end

  def quota_params
    params.require(:quota).permit(:value, :user_id, :time_period_id, :value_type, :product_id, :product_type)
  end

  def import_message
    'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file '\
     'size)'
  end

  def csv_import_worker_perform
    CsvImportWorker.perform_async(
      params[:file][:s3_file_path],
      'Csv::Quota',
      current_user.id,
      params[:file][:original_filename]
    )
  end
end
