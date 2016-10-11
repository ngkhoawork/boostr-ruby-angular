class Api::DealProductsController < ApplicationController
  respond_to :json

  def create
    deal_product = deal.deal_products.new(
      product_id: deal_product_params[:product_id],
      budget: deal_product_params[:budget],
      start_date: deal.start_date,
      end_date: deal.end_date
    )
    if deal_product.save
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
    params.require(:deal_product).permit(:budget, :product_id)
  end

  # def create
  #   deal.add_product(product.id, params[:total_budget])
  #   render deal
  # end

  # def update
  #   if deal_product_budget.update_attributes(deal_product_budget_params)
  #     render deal
  #   else
  #     render json: { errors: deal_product_budget.errors.messages }, status: :unprocessable_entity
  #   end
  # end

  # def destroy
  #   deal.remove_product(params[:id])
  #   render deal
  # end

  # def update_total_budget
  #   deal.update_product_budget(params[:product_id], params[:total_budget])
  #   render deal
  # end

  # private

  # def deal
  #   @deal ||= current_user.company.deals.find(params[:deal_id])
  # end

  # def product
  #   @product ||= current_user.company.products.find(params[:product_id])
  # end

  # def deal_product_budget
  #   @deal_product_budget ||= deal.deal_product_budgets.find(params[:id])
  # end

  # def deal_product_budget_params
  #   params.require(:deal_product_budget).permit(:budget)
  # end
end