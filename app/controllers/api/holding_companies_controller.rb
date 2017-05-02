class Api::HoldingCompaniesController < ApplicationController
  respond_to :json

  def index
    render json: holding_companies
  end

  private

  def holding_companies
    @holding_companies ||= HoldingCompany.all
  end
end
