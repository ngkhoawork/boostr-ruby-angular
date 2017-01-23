class Api::DealProductsController < ApplicationController
  respond_to :json

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DealProduct.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    else
      converted_params = ConvertCurrency.call(deal, deal_product_params)
      deal_product = deal.deal_products.new(converted_params)
      deal_product.update_periods if params[:deal_product][:deal_product_budgets_attributes]
      if deal_product.save
        deal.update_total_budget
        render deal
      else
        render json: { errors: deal_product.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    converted_params = ConvertCurrency.call(deal, deal_product_params)
    if deal_product.update_attributes(converted_params)
      deal.update_total_budget
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
      :budget_loc,
      :product_id,
      {
        deal_product_budgets_attributes: [:id, :budget_loc]
      }
    )
  end
end
