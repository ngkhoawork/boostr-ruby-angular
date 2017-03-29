class Api::V1::ForgotPasswordController < ApiController
  respond_to :json
  skip_before_action :authenticate_token_user, only: :create

  def create
    if forgot_password_params.presence
      User.where.not(email: nil).find_by_email(forgot_password_params).try(:send_reset_password_instructions)
      render json: {message: 'If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.'}, status: :created
    else
      render json: {error: 'Missing or empty parameter email'}, status: :bad_request
    end
  end

  private

  def forgot_password_params
    params.fetch(:email, nil)
  end
end
