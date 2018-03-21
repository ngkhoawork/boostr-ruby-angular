class ApiConfigurationService < BaseService
  def create_api_configuration
    if params[:integration_provider].eql?('Ssp')
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
    case params[:type_id]
    when 1
      { ssp_id: search_ssp('spotx_aws'), parser_type: 'SpotX' }
    when 2
      { ssp_id: search_ssp('rubicon'), parser_type: 'Rubicon' }
    end
  end

  def ssp_params
    {
      key: params[:key],
      secret: params[:secret],
      publisher_id: params[:publisher_id],
      type_id: params[:type_id],
      switched_on: params[:switched_on],
      integration_type: 'SspCredential',
      ssp_id: params[:ssp_id],
    }.merge(parser_type)
  end
end
