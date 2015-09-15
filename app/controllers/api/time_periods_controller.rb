class Api::TimePeriodsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.time_periods
  end

  def create
    time_period = current_user.company.time_periods.new(time_period_params)
    if time_period.save
      render json: time_period, status: :created
    else
      render json: { errors: time_period.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    time_period.destroy
    render nothing: true
  end

  private

  def time_period_params
    params.require(:time_period).permit(:name, :start_date, :end_date)
  end

  def time_period
    @time_period ||= current_user.company.time_periods.find(params[:id])
  end
end
