class Api::Settings::AssignmentRulesController < ApplicationController
  def index
    render json: assignment_rules, each_serializer: Api::AssignmentRules::IndexSerializer
  end

  private

  def company
    current_user.company
  end

  def assignment_rules
    AssignmentRule.by_company_id(company.id)
  end
end
