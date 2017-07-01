class AsanaConnect < ActiveRecord::Base
  def self.url(user_id)
    oauth_client.auth_code.authorize_url(state: user_id)
  end

  def self.callback(params)
    if params[:code]
      token = oauth_client.auth_code.get_token(params[:code])
      create_api_configuration(token, params[:state])
    end
  end

  private

  def self.oauth_client
    @_oauth_client ||= OAuth2::Client.new(
      ASANA_CONNECT.client_id,
      ASANA_CONNECT.client_secret,
        authorize_url: ASANA_CONNECT.authorize_url,
        redirect_uri: ASANA_CONNECT.redirect_uri,
        token_url: ASANA_CONNECT.token_url,
        site: ASANA_CONNECT.site,
        grant_type: 'refresh_token'
    )
  end

  def self.create_api_configuration(token, user_id)
    company_id = User.find(user_id).company_id
    params = {
      company_id: company_id,
      base_link: 'https://app.asana.com/-/oauth_authorize',
      api_email: token.params['data']['email'],
      password: token.refresh_token,
    }
    api_config = ApiConfiguration.find_or_initialize_by(company_id: company_id, integration_provider: Integration::ASANA_CONNECT)
    api_config.update(params)
  end

  def persisted?
    false
  end
end
