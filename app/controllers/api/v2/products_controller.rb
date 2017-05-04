class Api::V2::ProductsController < ApiController
  respond_to :json

  def index
    products = current_user.company.products
    render json: products
  end
end
