class AsanaConnectConfiguration < ApiConfiguration
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base
end
