class DatafeedConfigurationDetails < ActiveRecord::Base
  belongs_to :operative_datafeed_configuration

  validates_inclusion_of :auto_close_deals, in: [true, false]
end
