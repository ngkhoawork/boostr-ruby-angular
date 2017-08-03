class Api::ApiConfigurationsController < ApplicationController
  respond_to :json

  def index
    render json: API::ApiConfigurations::Collection.new(api_configurations)
  end

  def update
    if api_configuration.update(api_configuration_params)
      render json: API::ApiConfigurations::Single.new(api_configuration)
    else
      render json: { errors: api_configuration.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    api_configuration_service = ApiConfigurationService.new(current_user: current_user, params: api_configuration_params)

    if api_configuration = api_configuration_service.create_api_configuration
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

  def api_configurations
    @_api_configurations ||= ApiConfiguration.where(company_id: current_user.company.id)
  end

  def api_configuration_params
    params.require(:api_configuration).permit(:id,
                                              :integration_type,
                                              :integration_provider,
                                              :switched_on,
                                              :trigger_on_deal_percentage,
                                              :company_id,
                                              :base_link,
                                              :password,
                                              :api_email,
                                              :json_api_key,
                                              :network_code,
                                              :recurring,
                                              cpm_budget_adjustment_attributes: [:id,
                                                                                 :percentage,
                                                                                 :created_at,
                                                                                 :updated_at,
                                                                                 :api_configuration_id],
                                              dfp_report_queries_attributes:    [:id,
                                                                                 :report_type,
                                                                                 :monthly_recurrence_day,
                                                                                 :report_id,
                                                                                 :weekly_recurrence_day,
                                                                                 :is_daily_recurrent,
                                                                                 :api_configuration_id,
                                                                                 :date_range_type],
                                              asana_connect_details_attributes: [:id,
                                                                                 :project_name,
                                                                                 :workspace_name
                                                                                ])
  end
end
