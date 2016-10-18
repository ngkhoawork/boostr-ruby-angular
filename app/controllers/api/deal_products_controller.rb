class Api::DealProductsController < ApplicationController
  respond_to :json

  def create
    deal_product = deal.deal_products.new(deal_product_params)
    if deal_product.save
      deal.update_total_budget
      render deal
    else
      render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if deal_product.update_attributes(deal_product_params)
      render deal
    else
      render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal_product.destroy
    deal.update_total_budget
    render deal
  end

  private

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def deal_product
    @deal_product ||= deal.deal_products.find(params[:id])
  end

  def deal_product_params
    params.require(:deal_product).permit(
      :budget,
      :product_id,
      {
        deal_product_budgets_attributes: [:id, :budget]
      }
    )
  end
end
