class Api::V2::TokenCheckController < ApiController
  def index
    render json: { success: 'Authentication Valid' }, status: :ok
  end
end
