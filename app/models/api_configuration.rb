class ApiConfiguration < ActiveRecord::Base
  INTEGRATION_PROVIDERS = ['google', 'operative', 'Operative Datafeed']

  serialize :json_api_key, JSON

  belongs_to :company

  validates :base_link, presence: true, uniqueness: true, unless: :is_google_integration?
  validates :company_id,:integration_type, presence: true
  validates :api_email, :encrypted_password, presence: true, unless: :is_google_integration?
  validates :integration_type, inclusion: { in: INTEGRATION_PROVIDERS }
  validates :json_api_key, presence: true, if: :is_google_integration?

  attr_encrypted :password, key: Rails.application.secrets.secret_key_base
  attr_encrypted :json_api_key, key: Rails.application.secrets.secret_key_base, marshal: true

  private

  def is_google_integration?
    integration_type == 'google'
  end

end
