FactoryGirl.define do
  factory :datafeed_configuration_details do
    auto_close_deals false
    skip_not_changed false
    revenue_calculation_pattern { DatafeedConfigurationDetails::REVENUE_CALCULATION_PATTERNS.sample[:id] }
  end
end
