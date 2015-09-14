class Api::QuotasController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.quotas.for_time_period(params[:time_period_id])
  end
end