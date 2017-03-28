class UserTokenController < Knock::AuthTokenController
  rescue_from Knock.not_found_exception_class, with: :user_not_found

  def user_not_found
    render json: { error: 'Not Found' }, status: :not_found
  end
end
