FactoryGirl.define do
  factory :client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
  end

  factory :advertiser, class: Client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
    client_type 'Advertiser'
  end

  factory :agency, class: Client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
    client_type 'Agency'
  end
end
