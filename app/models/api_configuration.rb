class ApiConfiguration < ActiveRecord::Base
  belongs_to :company

  validates :base_link, presence: true, uniqueness: true
  validates :company_id, :api_email, :encrypted_password, :integration_type, presence: true

  attr_encrypted :password, key: Rails.application.secrets.secret_key_base
end
