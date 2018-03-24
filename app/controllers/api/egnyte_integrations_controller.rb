class Api::EgnyteIntegrationsController < ApplicationController
  respond_to :json

  WEBSITE_EGNYTE_SETTINGS_URL = '/settings/egnyte'.freeze

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
    if resource.update(connected: false, access_token: nil)
      render json: resource
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def oauth_settings
    raise 'oauth settings can not be provided for a connected resource' if resource.connected?

    if resource.enabled?
      state_token = Egnyte::Actions::BuildAuthorizationUri.generate_state_token(resource.app_domain)

      resource.update(access_token: state_token)

      render json: { egnyte_login_uri: build_user_authorization_uri(state_token) }
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

  def oauth_callback
    connect_egnyte

    redirect_to WEBSITE_EGNYTE_SETTINGS_URL
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
      .slice(:app_domain, :enabled, :connected, :deal_folder_tree, :account_folder_tree)
  end

  def build_user_authorization_uri(state_token)
    Egnyte::Actions::BuildAuthorizationUri.new(
      domain: resource.app_domain,
      redirect_uri: oauth_callback_api_egnyte_integration_url(protocol: 'https'),
      state: state_token
    ).perform
  end

  def connect_egnyte
    Egnyte::Actions::Connect.new(
      code: params.require(:code),
      redirect_uri: oauth_callback_api_egnyte_integration_url,
      state: params[:state]
    ).perform
  end

  def navigate_deal_uri
    Egnyte::Actions::GetNavigateUri::Deal.new(
      egnyte_integration_id: resource.id,
      deal_id: params.require(:deal_id)
    ).perform
  end

  def navigate_account_deals_uri
    Egnyte::Actions::GetNavigateUri::AccountDeals.new(
      egnyte_integration_id: resource.id,
      advertiser_id: params.require(:advertiser_id)
    ).perform
  end
end
