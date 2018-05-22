class Notification < ActiveRecord::Base
  LOST_DEAL = 'Lost Deal'.freeze
  PMP_STOPPED_RUNNING = 'PMP-stopped Running'.freeze
  DATAFEED_STATUS = 'Datafeed Status'.freeze
  TYPES = {'no_match_io'=> 1}.freeze
  scope :active, ->{ where(active: true) }

  belongs_to :company
  
  validates :name, presence: true

  scope :active_pipeline_changes_notifications, -> { where('notifications.active = true AND notifications.name = \'Pipeline Changes Reports\'') }
  scope :active_error_log_notifications, -> { where('notifications.active = true AND notifications.name = \'Error Log\'') }
  scope :active_dfp_notifications, -> { where('notifications.active = true AND notifications.name = \'DFP Notifications\'') }
  scope :by_name, -> (name) { find_by(name: name) }

  def recipients_arr
    recipients.blank? ? [] : recipients.split(',').map(&:strip)
  end
end

