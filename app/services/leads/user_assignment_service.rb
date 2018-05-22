class Leads::UserAssignmentService
  NON_USA_STATE = /\bnot|non\b/

  def perform
    lead.update_column(:user_id, next_available_user)

    update_rules_next_fields_value
  end

  def initialize(lead)
    @lead = lead
  end

  def next_available_user
    find_next_available_rule.user_id
  end

  private

  delegate :state, :country, :product_name, :source_url, :company_id, to: :lead

  attr_reader :lead

  def update_rules_next_fields_value
    return if find_rule.assignment_rules_users.count < 1

    find_next_available_rule.update(next: false)

    next_assignment_rules_user.present? ?
      next_assignment_rules_user.update(next: true) : first_assignment_rules_user.update(next: true)
  end

  def find_rule
    @_rule ||= determine_rule.blank? ? default_rule : determine_rule
  end

  def determine_rule
    @_determined_rule ||=
      [rule_by_source, rule_by_product, rule_by_country_field].compact.sort_by { |rule| rule.position }.first
  end

  def rule_by_country_field
    return nil if country.blank?

    state_blank_or_match_non_usa? ? rule_by_countries : rule_by_states_and_countries
  end

  def state_blank_or_match_non_usa?
    state.blank? || state.downcase.match(NON_USA_STATE).to_s.present?
  end

  def default_rule
    AssignmentRule
      .by_company_id(company_id)
      .find_by(default: true)
  end

  def country_type_rules
    @_country_type_rules ||= assignment_rules.by_type(AssignmentRule::COUNTRY)
  end

  def source_type_rules
    @_source_type_rules ||= assignment_rules.by_type(AssignmentRule::SOURCE_URL)
  end

  def product_type_rules
    @_product_type_rules ||= assignment_rules.by_type(AssignmentRule::PRODUCT_NAME)
  end

  def assignment_rules
    @_assignment_rules ||=
      AssignmentRule
        .by_company_id(company_id)
        .not_default
        .order_by_position
  end

  def rule_by_countries
    country_type_rules.by_criteria_1(country).first
  end

  def rule_by_states_and_countries
    country_type_rules.by_criteria_2(state).by_criteria_1(country).first
  end

  def rule_by_source
    return nil if source_url.blank?

    source_type_rules.by_criteria_1(source_url).first
  end

  def rule_by_product
    return nil if product_name.blank?

    product_type_rules.by_criteria_1(product_name).first
  end

  def find_next_available_rule
    @_next_available_rule ||= find_rule.next_available_rule
  end

  def next_assignment_rules_user
    @_next_assignment_rules_user ||=
      find_rule.assignment_rules_users.find_by(position: find_next_available_rule.position.next)
  end

  def first_assignment_rules_user
    find_rule.assignment_rules_users.first
  end
end
