class Notification < ActiveRecord::Base
  belongs_to :company
  
  validates :name, presence: true

  scope :active_pipeline_changes_notifications, -> { where('notifications.active = true AND notifications.name = \'Pipeline Changes Reports\'') }
  scope :active_error_log_notifications, -> { where('notifications.active = true AND notifications.name = \'Error Log\'') }

  def recipients_arr
    return [] if recipients.blank?
    recipients.split(',').map(&:strip)
  end
end
