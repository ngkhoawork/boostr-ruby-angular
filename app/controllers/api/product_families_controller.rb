class Api::ProductFamiliesController < ApplicationController
  respond_to :json

  def index
    render json: product_families
  end

  def create
    new_product_family = product_families.new(product_family_params)
    if new_product_family.save
      render json: new_product_family, status: :created
    else
      render json: { errors: new_product_family.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if product_family.update_attributes(product_family_params)
      render json: product_family, status: :accepted
    else
      render json: { errors: product_family.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if product_family.destroy
      render nothing: true
    else
      render json: { errors: product_family.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def product_families
    @_product_families ||= current_user.company.product_families.active(params[:active])
  end

  def product_family_params
    params.require(:product_family).permit(:name, :active)
  end

  def product_family
    @_product_family ||= product_families.find_by(id: params[:id])
  end
end
