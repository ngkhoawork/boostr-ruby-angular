class ApiConfiguration < ActiveRecord::Base
  belongs_to :company

  validates :base_link, presence: true, uniqueness: true
  validates :company_id, presence: true
  validates :api_email, :encrypted_password, presence: true

  attr_encrypted :password, key: Rails.application.secrets.secret_key_base
end
