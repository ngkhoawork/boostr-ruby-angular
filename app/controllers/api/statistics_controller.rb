class Api::StatisticsController < ApplicationController
  respond_to :json

  def show
    statistics = Statistic.by_pmp_id(statistics_params[:id]).limit(5)
    render json: statistics, each_serializer: StatisticSerializer
  end

  private

  def statistics_params
    params.permit(:id)
  end
end
