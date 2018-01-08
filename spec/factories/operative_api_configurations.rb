FactoryBot.define do
  factory :operative_api_configuration do
    integration_type OperativeApiConfiguration
    integration_provider 'operative'
    switched_on true
    trigger_on_deal_percentage 100
    base_link 'https://config.operativeone.com'
    api_email 'api_user@kingsandbox.com'
    password 'King2017!'

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
