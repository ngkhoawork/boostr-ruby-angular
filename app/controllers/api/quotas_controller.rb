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

  private

  def time_period
    @time_period = current_user.company.time_periods.find(params[:time_period_id])
  end

  def quotas
    if params[:time_period_id].present?
      # start_date = Time.parse(time_period.start_date.to_s).utc.beginning_of_day
      # end_date = Time.parse(time_period.end_date.to_s).utc.end_of_day
      # current_user.company.quotas.for_time_period(start_date, end_date)
      time_period.quotas
    else
      current_user.company.quotas
    end
  end

  def quota
    @quota ||= current_user.company.quotas.find(params[:id])
  end

  def quota_params
    params.require(:quota).permit(:value, :user_id, :time_period_id)
  end
end
