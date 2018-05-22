class SlackConnector
  class << self
    def url(company_id)
      oauth_client.auth_code.authorize_url(state: company_id, scope: scopes)
    end

    def callback(params)
      if params[:code]
        result = oauth_client.auth_code.get_token(params[:code])
        token = result.token

        create_api_configuration(token, params[:state])
      elsif params[:error]
        disable_api_configuration(params[:state])
      end
    end

    private

    def scopes
      %w(channels:write channels:read chat:write:bot).join(', ')
    end

    def oauth_client
      @_oauth_client ||= OAuth2::Client.new(
          SLACK_CONNECT.client_id,
          SLACK_CONNECT.client_secret,
          site: 'https://slack.com/',
          authorize_url: '/oauth/authorize',
          token_url: '/api/oauth.access',
          redirect_uri: SLACK_CONNECT.redirect_uri
      )
    end

    def create_api_configuration(token, company_id)
      params = { password: token, switched_on: true }

      api_config = SlackApiConfiguration.find_or_initialize_by(company_id: company_id, integration_provider: Integration::SLACK)
      api_config.update(params)
      update_wf_actions(company_id, api_config&.id)
    end

    def update_wf_actions(company_id, api_connection_id)
      company = Company.find(company_id)
      return unless company.present?
      wf_ids = company.workflows.pluck(:id)
      return unless wf_ids.present?
      WorkflowAction.where(workflow_id: wf_ids)&.map{|c|c.update_attribute(:api_configuration_id, api_connection_id)}
    end

    def disable_api_configuration(company_id)
      api_config = SlackApiConfiguration.find_or_initialize_by(company_id: company_id, integration_provider: Integration::SLACK)
      api_config.update(switched_on: false)
    end
  end
end

