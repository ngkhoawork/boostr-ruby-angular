class AuditLog < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :user
  belongs_to :company
  belongs_to :deal_member

  validates :changed_field, :old_value, :new_value, :user_id, :company_id, presence: true
end
