class API::IntegrationLogs::Single < API::Single
  properties :id,
             :response_code,
             :response_body,
             :api_endpoint,
             :deal_id,
             :request_type,
             :created_at,
             :is_error,
             :error_text,
             :object_name
end