class OperativeDatafeedConfiguration < ApiConfiguration
  validates :api_email, :encrypted_password, presence: true
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base

  has_one :datafeed_configuration_details, foreign_key: :api_configuration_id, dependent: :destroy
  accepts_nested_attributes_for :datafeed_configuration_details

  delegate :auto_close_deals, :revenue_calculation_pattern, :product_mapping,
           to: :datafeed_configuration_details, prefix: false

  def self.metadata
    {
      revenue_calculation_patterns: DatafeedConfigurationDetails::REVENUE_CALCULATION_PATTERNS,
      product_mapping: DatafeedConfigurationDetails::PRODUCT_MAPPING
    }
  end
end
