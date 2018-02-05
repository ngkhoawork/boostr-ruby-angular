class ApiConfigurationService < BaseService
  def create_api_configuration
    user_company.send(get_association_sym).create!(params)
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
end
