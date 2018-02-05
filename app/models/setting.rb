class Setting < ActiveRecord::Base
  validates :var, presence: true

  VALID_SETTINGS = [
      :gcalendar_extension_url,
      :gmail_extension_url
  ].freeze

  SETTING_NAMES = {
    :gcalendar_extension_url => 'GCalendar Extension URL',
    :gmail_extension_url => 'Gmail Extension URL'  
  }.freeze

  def self.valid
    VALID_SETTINGS.map do |setting|
      self.find_or_initialize_by(var: setting)
    end
  end

  def self.get(key)
    self.where(var: key).first.try(:value)
  end

  def name
    SETTING_NAMES[var.to_sym] || var.humanize
  end
end
