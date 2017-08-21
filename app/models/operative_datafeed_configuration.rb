class OperativeDatafeedConfiguration < ApiConfiguration
  validates :api_email, :encrypted_password, presence: true
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base

  has_one :datafeed_configuration_details, foreign_key: :api_configuration_id, dependent: :destroy
  accepts_nested_attributes_for :datafeed_configuration_details

  delegate :auto_close_deals, to: :datafeed_configuration_details, prefix: false
end
