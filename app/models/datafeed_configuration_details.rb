class DatafeedConfigurationDetails < ActiveRecord::Base
  belongs_to :operative_datafeed_configuration

  validates_inclusion_of :auto_close_deals, in: [true, false]
  validates_presence_of :revenue_calculation_pattern

  REVENUE_CALCULATION_PATTERNS = [
    { id: 0, name: 'Invoice Units' },
    { id: 1, name: 'Recognized Revenue' },
    { id: 2, name: 'Invoice Amount' }
  ]
end
