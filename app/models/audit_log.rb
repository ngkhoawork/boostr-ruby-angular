class AuditLog < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :user, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :company

  validates :type_of_change, :biz_days, :updated_by, :company_id, presence: true
end
