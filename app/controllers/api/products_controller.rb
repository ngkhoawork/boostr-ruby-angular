class Api::ProductsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.products
  end

  def create
    product = current_user.company.products.new(product_params)
    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if product.update_attributes(product_params)
      render json: product, status: :accepted
    else
      render json: { errors: product.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :family, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def product
    @product ||= current_user.company.products.where(id: params[:id]).first
  end
end
