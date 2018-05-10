class AssignmentRulesUser < ActiveRecord::Base
  belongs_to :assignment_rule
  belongs_to :user

  before_create :set_position, :set_next_user_for_first_created_record_in_assignment_rule_scope
  before_destroy :set_next_user_to_last_rule

  validates :user_id, uniqueness: { scope: :assignment_rule_id, message: 'User should be unique per rule' }

  scope :not_next, -> { where(next: false) }
  scope :order_by_position, -> { order(:position) }

  def next_record
    related_assignment_rules_users
      .where('id > ?', id)
      .order(:id)
      .first
  end

  private

  def set_position
    self.position =
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
    if self.next && not_next_related_assignment_rules_users.present?
      not_next_related_assignment_rules_users.last.update(next: true)
    end
  end

  def self.next_available
    find_by(next: true)
  end

  def related_assignment_rules_users
    @_related_assignment_rules_users ||= self.assignment_rule.assignment_rules_users
  end

  def not_next_related_assignment_rules_users
    @_not_next_related_assignment_rules_users ||= related_assignment_rules_users.not_next
  end
end
