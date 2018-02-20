class AssignmentRulesUser < ActiveRecord::Base
  belongs_to :assignment_rule
  belongs_to :user

  before_create :set_position, :set_next_user_for_first_created_record_in_assignment_rule_scope

  validates :user_id, uniqueness: { scope: :assignment_rule_id, message: 'User should be unique per rule' }

  private

  def set_position
    self.position ||= self.assignment_rule.assignment_rules_users.count
  end

  def set_next_user_for_first_created_record_in_assignment_rule_scope
    self.next = true if self.assignment_rule.assignment_rules_users.length <= 1
  end

  def self.next_available
    find_by(next: true)
  end
end
