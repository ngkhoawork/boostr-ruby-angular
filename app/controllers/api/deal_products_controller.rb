class Api::DealProductsController < ApplicationController
  respond_to :json

  def create
    deal.add_product(product, params[:total_budget])
    render deal
  end

  private

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end

  def product
    @product ||= current_user.company.products.find(params[:product_id])
  end
end