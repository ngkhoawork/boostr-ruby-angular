class Api::Settings::AssignmentRulesController < ApplicationController
  def index
    render json: AssignmentRule.by_company_id(company.id)
  end

  private

  def company
    current_user.company
  end
end
