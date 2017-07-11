class Api::AccountDimensionsController < ApplicationController
  def index
    render json: account_dimensions
  end

  private

  def account_dimensions
    @account_dimensions ||= if params[:holding_company_id]
                              AccountDimension.where(holding_company_id: params[:holding_company_id], account_type: Client::AGENCY)
                            else
                              AccountDimension.where(company_id: current_user.company_id, account_type: Client::AGENCY)
                            end

  end
end