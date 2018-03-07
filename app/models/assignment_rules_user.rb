class AssignmentRulesUser < ActiveRecord::Base
  belongs_to :assignment_rule
  belongs_to :user

  before_create :set_position, :set_next_user_for_first_created_record_in_assignment_rule_scope
  before_destroy :set_next_user_to_last_rule

  validates :user_id, uniqueness: { scope: :assignment_rule_id, message: 'User should be unique per rule' }

  scope :not_next, -> { where(next: false) }
  scope :order_by_position, -> { order(:position) }

  private

  def set_position
    self.position ||=
      related_assignment_rules_users
        .order_by_position
        .last
        .position
        .next rescue 1
  end

  def set_next_user_for_first_created_record_in_assignment_rule_scope
    self.next = true if related_assignment_rules_users.length <= 1
  end

  def set_next_user_to_last_rule
    related_assignment_rules_users.not_next.last.update(next: true) if self.next
  end

  def self.next_available
    find_by(next: true)
  end

  def related_assignment_rules_users
    @_related_assignment_rules_users ||= self.assignment_rule.assignment_rules_users
  end
end
