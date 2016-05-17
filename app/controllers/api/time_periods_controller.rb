class Api::TimePeriodsController < ApplicationController
  respond_to :json

  def index
    now = current_user.company.time_periods.now.as_json
    time_periods = current_user.company.time_periods.as_json.map do |time_period|
      if time_period['id'] == now['id']
        time_period['is_now'] = true
      end
      time_period
    end
    render json: time_periods
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
