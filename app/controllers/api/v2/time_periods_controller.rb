class Api::V2::TimePeriodsController < ApiController
  respond_to :json

  def index
    now = current_user.company.time_periods.now.as_json
    time_periods = current_user.company.time_periods.as_json

    if now
      time_periods = time_periods.map do |time_period|
        if time_period['id'] == now['id']
          time_period['is_now'] = true
        end
        time_period
      end
    end
    render json: time_periods
  end

  private

  def time_period_params
    params.require(:time_period).permit(:name, :start_date, :end_date)
  end

  def time_period
    @time_period ||= current_user.company.time_periods.find(params[:id])
  end
end
