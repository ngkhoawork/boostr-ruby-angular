FactoryGirl.define do
  factory :client, aliases: [:advertiser] do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
  end
end
