class ApiConfigurationService < BaseService
  def create_api_configuration
    if params[:ssp_id].present?
      user_company.ssp_credentials.create!(ssp_params)
    else
      user_company.send(get_association_sym).create!(params)
    end
  end

  def get_configuration_class_name
    ApiConfiguration::INTEGRATION_PROVIDERS[params[:integration_provider].to_sym] || 'ApiConfiguration'
  end

  def get_association_sym
    get_configuration_class_name.underscore.pluralize.to_sym
  end

  def user_company
    current_user.company
  end

  def parser_type
    { parser_type: Ssp.find(params[:ssp_id])&.parser_type }
  end

  def ssp_params
    params.merge(type_id: params[:ssp_id], integration_type: 'SspCredential').merge(parser_type)
  end
end
