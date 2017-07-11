class AsanaConnectConfiguration < ApiConfiguration
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base

  has_one :asana_connect_details, foreign_key: :api_configuration_id, dependent: :destroy

  accepts_nested_attributes_for :asana_connect_details

  delegate :project_name, :workspace_name, to: :asana_connect_details, prefix: false
end
