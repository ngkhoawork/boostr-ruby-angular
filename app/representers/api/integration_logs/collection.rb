class API::IntegrationLogs::Collection < API::Collection
  collection :entries, extend: API::IntegrationLogs::Single, as: :integration_logs
end