class OperativeDatafeedConfiguration < ApiConfiguration
  validates :api_email, :encrypted_password, presence: true
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base
end
