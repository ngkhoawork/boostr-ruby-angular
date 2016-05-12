class Api::CompaniesController < ApplicationController
  respond_to :json

  def show
    render json: company.to_json
  end

  def update
    if company.update_attributes(company_params)
      puts company_params
      puts company
      render json: company
    else
      render json: { errors: company.errors.messages }, status: :unprocessable_entity
    end
  end

  protected

  def company_params
    params.require(:company).permit(:snapshot_day, :avg_day, :day1, :day2, :day3)
  end

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end
end
