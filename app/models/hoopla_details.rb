class HooplaDetails < ActiveRecord::Base
  belongs_to :configuration, class_name: 'HooplaConfiguration', foreign_key: :api_configuration_id, required: true

  before_validation :process_credentials

  def access_token_alive?
    DateTime.current.to_i < access_token_expires_at.to_i
  end

  def non_connected?
    !connected?
  end

  private

  def process_credentials
    connect if client_id_changed? || client_secret_changed?

    true
  end

  def connect
    return false unless client_id.present? && client_secret.present?

    response = perform_oauth

    if response.code == '200'
      self.access_token = response.body[:access_token]
      self.access_token_expires_at = DateTime.current + response.body[:expires_in].seconds
      self.connected = true
    else
      reset_connection
    end
  end

  def reset_connection
    self.access_token = nil
    self.access_token_expires_at = nil
    self.deal_won_newsflash_href = nil
    self.connected = false
    configuration&.switched_on = false
  end

  def perform_oauth
    Hoopla::Endpoints::Oauth.new(client_id: client_id, client_secret: client_secret).perform
  end
end
