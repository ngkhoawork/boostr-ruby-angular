FactoryBot.define do
  factory :datafeed_configuration_details do
    auto_close_deals false
    revenue_calculation_pattern { DatafeedConfigurationDetails::REVENUE_CALCULATION_PATTERNS.sample[:id] }
  end
end
