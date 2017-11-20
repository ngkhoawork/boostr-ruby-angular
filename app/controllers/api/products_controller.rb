class Api::ProductsController < ApplicationController
  respond_to :json, :csv

  def index
    products = current_user.company.products.by_revenue_type(params[:revenue_type])
    if params[:active] == 'true'
      products = products.active
    end

    respond_to do |format|
      format.json { render json: products }
      format.csv { send_data products.to_csv, filename: "products-#{Date.today}.csv" }
    end
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
    params.require(:product).permit(:name, :revenue_type, :active, :is_influencer_product, :product_family_id, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def product
    @product ||= current_user.company.products.where(id: params[:id]).first
  end
end
