class Api::QuotasController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.quotas.for_time_period(params[:time_period_id])
  end

  def update
    if quota.update_attributes(quota_params)
      render json: quota, status: :accepted
    else
      render json: { errors: quota.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def quota
    @quota ||= current_user.company.quotas.find(params[:id])
  end

  def quota_params
    params.require(:quota).permit(:value)
  end
end