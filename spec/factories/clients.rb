FactoryGirl.define do
  factory :client do
    sequence(:name) { |n| "Advertizer-#{n}" }
    website "www.advertizer.com"
  end

end
