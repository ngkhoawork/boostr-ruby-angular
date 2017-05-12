class Api::PacingDashboardController < ApplicationController
  respond_to :json

	def pipeline_and_revenue
		respond_with pipeline_and_revenue_serializer.merge({series: pipeline_and_revenue_series})
	end

	def activity_pacing
		respond_with activity_pacing_serializer.merge({series: activity_pacing_series})
	end

  private

  def company
    @_company ||= current_user.company
  end

  def pipeline_and_revenue_serializer
    PacingDashboard::PipelineAndRevenueSerializer.new(company).serializable_hash
  end

  def pipeline_and_revenue_series
    PacingDashboard::PipelineAndRevenueCalculationService.new(company).perform
	end

	def activity_pacing_serializer
		PacingDashboard::ActivityPacingSerializer.new(company).serializable_hash
	end

	def activity_pacing_series
		PacingDashboard::ActivityPacingCalculationService.new(company).perform
	end
end
