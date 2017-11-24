class Api::WeightedPipelinesController < ApplicationController
  respond_to :json

  def show
    render json: weighted_pipeline_serializer
  end

  private

  def weighted_pipeline_serializer
    Forecast::PipelineDataService.new(company, params).perform
  end

  def company
    @_company ||= current_user.company
  end
end
