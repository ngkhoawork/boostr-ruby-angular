class API::ApiConfigurations::Collection < API::Collection
  collection :entries, extend: API::ApiConfigurations::Single, as: :api_configurations
end