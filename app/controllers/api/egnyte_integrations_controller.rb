class Api::EgnyteIntegrationsController < ApplicationController
  respond_to :json

  def website_egnyte_settings_uri
    "https://#{host}/settings/egnyte"
  end

  def host
    Rails.application.config.action_mailer.default_url_options.tap do |host_options|
      break "#{host_options[:host]}:#{host_options[:port]}"
    end
  end

  def show
    render json: resource
  end

  def create
    @resource = company.build_egnyte_integration(resource_params)

    if resource.save
      render json: resource, status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: resource
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def disconnect_egnyte
    if resource.update(access_token: nil)
      render json: resource
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def oauth_settings
    if resource.app_domain.present?
      state_token = Egnyte::Actions::BuildAuthorizationUri.generate_state_token(resource.app_domain)

      resource.update(access_token: state_token)

      render json: { egnyte_login_uri: build_user_authorization_uri(state_token) }
    else
      render json: { errors: ['app_domain must be setup'] }, status: :bad_request
    end
  end

  def oauth_callback
    @resource = EgnyteIntegration.find_by_state_token(params[:state])

    raise ActiveRecord::RecordNotFound, 'egnyte state can not be fitted' unless @resource

    if params[:code]
      oauth_request = build_oauth_request.tap { |req| req.perform }

      raise oauth_request.parsed_response_body.inspect unless oauth_request.success?

      resource.update(access_token: oauth_request.parsed_response_body[:access_token])
    else
      resource.update(access_token: nil)
    end

    redirect_to website_egnyte_settings_uri
  end

  private

  def resource
    @resource ||=
      company.egnyte_integration || (raise ActiveRecord::RecordNotFound, 'egnyte integration does not exist')
  end

  def company
    @company ||= current_user.company
  end

  def resource_params
    params
      .require(:egnyte_integration)
      .permit!
      .slice(:app_domain, :enabled, :deal_folder_tree, :account_folder_tree)
  end

  def build_user_authorization_uri(state_token)
    Egnyte::Actions::BuildAuthorizationUri.new(
      domain: resource.app_domain,
      redirect_uri: oauth_callback_api_egnyte_integration_url,
      state: state_token
    ).perform
  end

  def build_oauth_request
    Egnyte::Endpoints::Oauth.new(
      domain: resource.app_domain,
      redirect_uri: oauth_callback_api_egnyte_integration_url,
      code: params[:code]
    )
  end
end
