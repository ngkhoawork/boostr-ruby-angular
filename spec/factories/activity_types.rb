FactoryBot.define do
  factory :activity_type do
    name    { FFaker::HipsterIpsum.word }
    action  { FFaker::HipsterIpsum.phrase }
    icon    {"/assets/icons/#{FFaker::HipsterIpsum.word}"}
    sequence(:position) { |n| n }
    company
    css_class 'bstr-css-class'

    after(:create) do |item|
      item.company_id = Company.first.id unless item.company_id.present?
    end
  end
end
