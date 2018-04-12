class Api::V2::UserTokenController < Knock::AuthTokenController
  rescue_from Knock.not_found_exception_class, with: :user_not_found

  ### copy of create with OK status
  def extension
    render json: auth_token
  end

  def user_not_found
    render json: { error: 'User Not Found' }, status: :not_found
  end
end
