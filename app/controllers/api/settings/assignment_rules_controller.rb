class Api::Settings::AssignmentRulesController < ApplicationController
  before_filter :modify_assignment_rule_params, only: :update

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
      render json: assignment_rule
    else
      render json: { errors: assignment_rule.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    assignment_rule.destroy

    render nothing: true
  end

  def add_user
    assignment_rules_user = assignment_rule.assignment_rules_users.new(user: user)

    if assignment_rules_user.save
      render json: assignment_rule, serializer: Api::AssignmentRules::IndexSerializer
    else
      render json: { errors: assignment_rules_user.errors.messages }, status: :unprocessable_entity
    end
  end

  def remove_user
    assignment_rule.users.delete user

    render json: assignment_rule, serializer: Api::AssignmentRules::IndexSerializer
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
    AssignmentRule.by_company_id(company.id).order_by_position.includes(:users)
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

  def modify_assignment_rule_params
    params[:assignment_rule][:states] = [] if states_nil?
    params[:assignment_rule][:countries] = [] if countries_nil?
  end

  def states_nil?
    params[:assignment_rule].keys.include?('states') && params[:assignment_rule][:states].nil?
  end

  def countries_nil?
    params[:assignment_rule].keys.include?('countries') && params[:assignment_rule][:countries].nil?
  end
end
