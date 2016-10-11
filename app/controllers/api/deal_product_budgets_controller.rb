class Api::DealProductBudgetsController < ApplicationController
  respond_to :json

  def create
    deal.add_product(product.id, params[:total_budget])
    render deal
  end

  def update
    if deal_product_budget.update_attributes(deal_product_budget_params)
      render deal
    else
      render json: { errors: deal_product_budget.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def product
    @product ||= current_user.company.products.find(params[:product_id])
  end

  def deal_product_budget
    @deal_product_budget ||= deal.deal_product_budgets.find(params[:id])
  end

  def deal_product_budget_params
    params.require(:deal_product_budget).permit(:budget)
  end
end
