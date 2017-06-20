class Api::ApiConfigurationsController < ApplicationController

  def index
    api_configurations = ApiConfiguration.where(company_id: current_user.company.id)
    render json: API::ApiConfigurations::Collection.new(api_configurations)
  end

  def update
    if api_configuration.update!(api_configuration_params)
      render json: API::ApiConfigurations::Single.new(api_configuration)
    else
      render json: { errors: api_configuration.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    api_configuration = current_user.company.api_configurations.new(api_configuration_params)

    if api_configuration.save!
      render json: API::ApiConfigurations::Single.new(api_configuration)
    else
      render json: { errors: api_configuration.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    api_configuration.destroy
    render nothing: true
  end

  private

  def api_configuration
    @_api_configuration ||= ApiConfiguration.find(params[:id])
  end

  def api_configuration_params
    params.require(:api_configuration).permit(
      :id, :integration_type, :switched_on, :trigger_on_deal_percentage,
      :company_id, :base_link, :password, :api_email, :recurring
    )
  end
end
