FactoryGirl.define do
  factory :api_configuration do
    integration_type 'operative'
    switched_on true
    trigger_on_deal_percentage 100
    base_link 'https://config.operativeone.com'
    api_email 'api_user@kingsandbox.com'
    password 'King2017!'
  end
end
