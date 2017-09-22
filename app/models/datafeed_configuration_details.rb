class DatafeedConfigurationDetails < ActiveRecord::Base
  belongs_to :operative_datafeed_configuration

  validates_inclusion_of :auto_close_deals, in: [true, false]
  validates_presence_of :revenue_calculation_pattern

  REVENUE_CALCULATION_PATTERNS = [
    { id: 0, name: 'Invoice Units' },
    { id: 1, name: 'Recognized Revenue' },
    { id: 2, name: 'Invoice Amount' }
  ]

  PRODUCT_MAPPING = [
    { id: 0, name: 'Product_Name' },
    { id: 1, name: 'Forecast_Category' }
  ]

  def self.get_pattern_id(name)
    REVENUE_CALCULATION_PATTERNS.find{|el| el[:name] == name}&.dig(:id)
  end

  def self.get_pattern_name(id)
    REVENUE_CALCULATION_PATTERNS.find{|el| el[:id] == id}&.dig(:name)
  end

  def self.get_product_mapping_id(name)
    PRODUCT_MAPPING.find{|el| el[:name] == name}&.dig(:id)
  end

  def self.get_product_mapping_name(id)
    PRODUCT_MAPPING.find{|el| el[:id] == id}&.dig(:name)
  end
end
