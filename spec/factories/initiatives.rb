FactoryGirl.define do
  factory :initiative do
    sequence(:name) { |n| "Initiative #{n}" }
    goal 100000
    status 'Open'
  end
end
