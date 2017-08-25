class AuditLog < ActiveRecord::Base
  BUDGET_CHANGE_TYPE     = 'Budget Change'.freeze
  STAGE_CHANGE_TYPE      = 'Stage Change'.freeze
  START_DATE_CHANGE_TYPE = 'Start Date Change'.freeze
  MEMBER_ADDED_TYPE      = 'Member Added'.freeze
  MEMBER_REMOVED_TYPE    = 'Member Removed'.freeze
  SHARE_CHANGE_TYPE      = 'Share Change'.freeze

  belongs_to :auditable, polymorphic: true
  belongs_to :user, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :company

  validates :type_of_change, :company_id, presence: true

  scope :by_auditable_type, -> (type) { where(auditable_type: type) }
  scope :by_type_of_change, -> (type) { where(type_of_change: type) }
  scope :in_created_at_range, -> (date_range) { where(created_at: date_range) }
end
