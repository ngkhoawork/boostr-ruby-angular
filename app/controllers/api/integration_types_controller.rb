class Api::IntegrationTypesController < ApplicationController
  respond_to :json

  def index
    integration_types = [Integration::OPERATIVE, Integration::OPERATIVE_DATAFEED, Integration::DFP, Integration::ASANA_CONNECT, Integration::GOOGLE_SHEETS]
    render json: integration_types
  end
end
