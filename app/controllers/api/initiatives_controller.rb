class Api::InitiativesController < ApplicationController
  respond_to :json

  before_action :find_company

  def index
    respond_with Initiative.by_company(@company)
  end

  def create

  end

  private

  def find_company
    @company = current_user.company
  end
end
