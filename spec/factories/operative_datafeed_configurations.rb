FactoryBot.define do
  factory :operative_datafeed_configuration do
    integration_type OperativeDatafeedConfiguration
    integration_provider 'Operative Datafeed'
    switched_on true
    trigger_on_deal_percentage 100
    base_link 'ftpprod.operativeftphost.com'
    api_email 'email@test.com'
    password 'password'

    datafeed_configuration_details
  end
end
