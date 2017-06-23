class Api::AccountDimensionsController < ApplicationController
  def index
    render json: account_dimensions
  end

  private

  def account_dimensions
    AccountDimension.where(holding_company_id: params[:holding_company_id])
  end
end