class DfpApiConfiguration < ApiConfiguration
  serialize :json_api_key, JSON

  validates :json_api_key, presence: true
  attr_encrypted :json_api_key, key: Rails.application.secrets.secret_key_base, marshal: true
end
