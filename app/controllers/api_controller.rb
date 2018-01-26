class ApiController < ActionController::Base
  include PagesHelper
  include Knock::Authenticable

  before_filter :authenticate_token_user

  layout nil

  def current_user
    current_token_user
  end

  def set_current_user
    User.current = current_user
  end

  private

  def unauthorized_entity(entity_name)
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
