class Api::DealProductsController < ApplicationController
  respond_to :json

  def create
    deal.add_product(product.id, params[:total_budget])
    render deal
  end

  def update
    if deal_product.update_attributes(deal_product_params)
      render deal
    else
      render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal.remove_product(params[:id])
    render deal
  end

  def update_total_budget
    deal.update_product_budget(params[:product_id], params[:total_budget])
    render deal
  end

  private

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def product
    @product ||= current_user.company.products.find(params[:product_id])
  end

  def deal_product
    @deal_product ||= deal.deal_products.find(params[:id])
  end

  def deal_product_params
    params.require(:deal_product).permit(:budget)
  end
end
