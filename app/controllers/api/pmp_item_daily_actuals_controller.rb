class Api::PmpItemDailyActualsController < ApplicationController
  respond_to :json

  def index
    render json: ActiveModel::ArraySerializer.new(
      pmp_item_daily_actuals,
      each_serializer: Pmps::PmpItemDailyActualSerializer
    )
  end

  private

  def pmp
    @_pmp ||= company.pmps.find(params[:pmp_id])
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= pmp.pmp_item_daily_actuals
  end

  def company
    @_company ||= current_user.company
  end
end
