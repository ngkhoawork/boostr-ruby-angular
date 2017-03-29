class ApiController < ActionController::Base
  include Knock::Authenticable

  before_filter :authenticate_token_user

  layout nil

  def current_user
    current_token_user
  end

  private

  def unauthorized_entity(entity_name)
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
