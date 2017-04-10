FactoryGirl.define do
  factory :activity do
    activity_type_id 1
    activity_type_name "Phone Call"
    happened_at "2016-03-11 23:15:03"
    comment "Positive phone call"

    client
    deal
    user
    association :updated_by, factory: :user
    association :created_by, factory: :user

    contacts { build_list :contact, 1 }

    before(:create) do |activity|
      activity.company = Company.first if activity.company.blank?
      activity.updator = activity.user
      activity.creator = activity.user
    end
  end
end
