class Api::IntegrationTypesController < ApplicationController
  respond_to :json

  def index
    integration_types = [Integration::OPERATIVE, Integration::OPERATIVE_DATAFEED, Integration::DFP, Integration::ASANA_CONNECT]
    integration_types << Integration::GOOGLE_SHEETS if current_user.company.buzzfeed?

    render json: integration_types
  end
end
