class Api::IntegrationTypesController < ApplicationController
  respond_to :json

  def index
    integration_types = [Integration::OPERATIVE, Integration::OPERATIVE_DATAFEED, Integration::DFP]
    render json: integration_types
  end
end
