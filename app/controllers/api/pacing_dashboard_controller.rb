class Api::PacingDashboardController < ApplicationController
  respond_to :json

  def index
    respond_with pacing_dashboard_serializer.merge({series: weeks_data_series})
  end

  private

  def company
    @_company ||= current_user.company
  end

  def pacing_dashboard_serializer
    PacingDashboard::IndexSerializer.new(company).serializable_hash
  end

  def weeks_data_series
    PacingDashboardService.new(company).perform
  end
end
