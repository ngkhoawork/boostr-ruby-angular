class Api::AccountDimensionsController < ApplicationController
  def index
    render json: account_dimensions
  end

  private

  def account_dimensions
    AccountDimension
        .by_holding_company_id(params[:holding_company_id])
        .by_company_id(current_user.company_id)
        .by_account_type(Client::AGENCY)
  end
end