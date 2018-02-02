class NotificationReminder < ActiveRecord::Base
  belongs_to :lead

  scope :by_type, -> (type) { where(notification_type: type) }
end
