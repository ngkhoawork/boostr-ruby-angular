class Api::InvitationsController < Devise::InvitationsController
  respond_to :json

  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name]
    devise_parameter_sanitizer.for(:invite).concat [:first_name, :last_name]
  end
end