class DatafeedConfigurationDetails < ActiveRecord::Base
  belongs_to :operative_datafeed_configuration

  validates_inclusion_of :auto_close_deals, in: [true, false]
  validates_presence_of :revenue_calculation_pattern

  REVENUE_CALCULATION_PATTERNS = [
    { id: 0, name: 'Invoice Units' },
    { id: 1, name: 'Recognized Revenue' },
    { id: 2, name: 'Invoice Amount' }
  ]

  def self.get_pattern_id(name)
    self::REVENUE_CALCULATION_PATTERNS.find{|el| el[:name] == name}[:id]
  end

  def self.get_pattern_name(id)
    self::REVENUE_CALCULATION_PATTERNS.find{|el| el[:id] == id}[:name]
  end
end
