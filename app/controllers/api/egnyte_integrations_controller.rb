class Api::EgnyteIntegrationsController < ApplicationController
  respond_to :json

  WEBSITE_EGNYTE_SETTINGS_URL = '/settings/egnyte'.freeze

  def show
    render json: resource,
           serializer: Api::EgnyteIntegrations::BaseSerializer
  end

  def create
    if build_resource.save
      render json: resource,
             serializer: Api::EgnyteIntegrations::BaseSerializer,
             status: :created
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: resource,
             serializer: Api::EgnyteIntegrations::BaseSerializer
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def disconnect_user
    if egnyte_user_auth.update(access_token: nil)
      render nothing: true
    else
      render json: { errors: egnyte_user_auth.errors.messages },
             status: :unprocessable_entity
    end
  end

  def oauth_settings
    raise 'oauth settings can not be provided for an authenticated user' if current_user.egnyte_authenticated

    if resource.enabled?
      render json: { egnyte_login_uri: build_user_authorization_uri }
    else
      render json: { errors: ['must be enabled'] }, status: :bad_request
    end
  end

  def navigate_to_deal
    render json: { navigate_to_deal_uri: navigate_deal_uri }
  end

  def navigate_to_account_deals
    render json: { navigate_to_deal_uri: navigate_account_deals_uri }
  end

  def company_oauth_callback
    connect_egnyte(
      'EgnyteIntegration',
      company_oauth_callback_api_egnyte_integration_url(protocol: 'https', host: host)
    )

    redirect_to root_path
  end

  def user_oauth_callback
    connect_egnyte(
      'EgnyteAuthentication',
      user_oauth_callback_api_egnyte_integration_url(protocol: 'https', host: host)
    )

    redirect_to WEBSITE_EGNYTE_SETTINGS_URL
  end

  private

  def resource
    @resource ||=
      company.egnyte_integration || (raise ActiveRecord::RecordNotFound, 'egnyte integration is not present')
  end

  def build_resource
    @resource = company.build_egnyte_integration(resource_params)
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

  def build_user_authorization_uri
    Egnyte::Actions::BuildAuthorizationUri.new(
      domain: resource.app_domain,
      redirect_uri: user_oauth_callback_api_egnyte_integration_url(protocol: 'https', host: host),
      auth_record: egnyte_user_auth
    ).perform
  end

  def connect_egnyte(auth_record_type, redirect_uri)
    Egnyte::Actions::Connect.new(
      egnyte_integration_id: resource.id,
      state: params.require(:state),
      code: params.require(:code),
      auth_record_type: auth_record_type,
      redirect_uri: redirect_uri
    ).perform
  end

  def navigate_deal_uri
    Egnyte::Actions::GetNavigateUri::Deal.new(
      egnyte_integration_id: resource.id,
      user_auth_id: egnyte_user_auth.id,
      deal_id: params.require(:deal_id)
    ).perform
  end

  def navigate_account_deals_uri
    Egnyte::Actions::GetNavigateUri::AccountDeals.new(
      egnyte_integration_id: resource.id,
      user_auth_id: egnyte_user_auth.id,
      advertiser_id: params.require(:advertiser_id)
    ).perform
  end

  def egnyte_user_auth
    @egnyte_auth ||= current_user.egnyte_auth || current_user.create_egnyte_auth!
  end

  def host
    ENV['HOST'] || request.domain
  end
end
