class Api::InvitationsController < Devise::InvitationsController
  respond_to :json

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: resource.email
      end
      if resource.is_a?(User)
        resource.roles = params[:user][:roles]
        resource.save
      end
      render json: resource, status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  protected

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite).merge(company_id: current_inviter.company_id)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name]
    devise_parameter_sanitizer.for(:invite).concat(
      [:first_name, :last_name, :user_type, :title, :employee_id, :office, :is_legal]
    )
  end
end
