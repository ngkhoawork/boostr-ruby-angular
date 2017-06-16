class Api::PacingDashboardController < ApplicationController
  respond_to :json

  def pipeline_and_revenue
    respond_with pipeline_and_revenue_serializer.merge({series: pipeline_and_revenue_series})
  rescue NoMethodError => _e
    render_errors
  end

  def activity_pacing
    respond_with activity_pacing_serializer.merge({series: activity_pacing_series})
  rescue NoMethodError => _e
    render_errors
  end

  private

  def company
    @_company ||= current_user.company
  end

  def pipeline_and_revenue_serializer
    PacingDashboard::PipelineAndRevenueSerializer.new(company, time_period_id: time_period_id).serializable_hash
  end

  def pipeline_and_revenue_series
    PacingDashboard::PipelineAndRevenueCalculationService.new(company, params).perform
  end

  def activity_pacing_serializer
    PacingDashboard::ActivityPacingSerializer.new(company, time_period_id: time_period_id).serializable_hash
  end

  def activity_pacing_series
    PacingDashboard::ActivityPacingCalculationService.new(company, params).perform
  end

  def time_period_id
    @_time_period_id ||= params[:time_period_id]
  end

  def render_errors
    render json: { errors: "Error happened when company didn't have time periods of type Quarter" },
           status: :unprocessable_entity
  end
end
