FactoryGirl.define do
  factory :activity do
    contacts { [FactoryGirl.create(:contact)] }
    activity_type_id 1
    activity_type_name "Phone Call"
    happened_at "2016-03-11 23:15:03"
    comment "Positive phone call"

    company
    client
    deal
    user
    association :updated_by, factory: :user
    association :created_by, factory: :user

    transient do
      contacts_count 1
    end

    after(:create) do |activity, evaluator|
      create_list(:contact_with_activities, evaluator.contacts_count, activities: [activity])
    end
  end
end
