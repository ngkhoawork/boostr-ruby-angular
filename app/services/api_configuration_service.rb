class ApiConfigurationService < BaseService
  def create_api_configuration
    user_company.send(get_association_sym).create!(params)
  end

  def get_configuration_class_name
    case params[:integration_provider]
      when 'operative'
        'OperativeApiConfiguration'
      when 'Operative Datafeed'
        'OperativeDatafeedConfiguration'
      when 'DFP'
        'DfpApiConfiguration'
      when 'Asana Connect'
        'AsanaConnectConfiguration'
      else
        'ApiConfiguration'
    end
  end

  def get_association_sym
    get_configuration_class_name.underscore.pluralize.to_sym
  end

  def user_company
    current_user.company
  end

end