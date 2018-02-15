class Api::Settings::AssignmentRulesController < ApplicationController
  def index
    render json: assignment_rules, each_serializer: Api::AssignmentRules::IndexSerializer
  end

  def create
    assignment_rule = AssignmentRule.new(assignment_rule_params)

    if assignment_rule.save
      render json: { status: 'Assignment Rule was successfully created' }, status: :created
    else
      render json: { errors: assignment_rule.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if assignment_rule.update(assignment_rule_params)
      render json: { status: 'Assignment Rule was successfully updated' }
    else
      render json: { errors: assignment_rule.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    assignment_rule.destroy

    render nothing: true
  end

  def add_user
    assignment_rule.users.push user

    render nothing: true
  end

  def remove_user
    assignment_rule.users.delete user

    render nothing: true
  end

  def update_positions
    positions = params[:positions]
    rules = assignment_rules.where(id: positions.keys)

    rules.each do |assignment_rule|
      assignment_rule.update(position: positions[assignment_rule.id.to_s])
    end

    render json: rules
  end

  private

  def company
    current_user.company
  end

  def assignment_rules
    AssignmentRule.by_company_id(company.id).order_by_position
  end

  def assignment_rule
    AssignmentRule.find(params[:id])
  end

  def assignment_rule_params
    params
      .require(:assignment_rule)
      .permit(:name, countries: [], states: [])
      .merge(company_id: company.id)
  end

  def user
    company.users.find(params[:user_id])
  end
end
