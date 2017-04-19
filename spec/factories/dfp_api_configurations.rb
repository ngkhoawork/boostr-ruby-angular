FactoryGirl.define do
  factory :dfp_api_configuration do
    json_api_key { { some_key: ''} }
    company
    network_code { rand(100000) }
    integration_provider 'DFP'
  end
end
