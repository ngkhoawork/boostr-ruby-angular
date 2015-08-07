FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.safe_email }
    password { FFaker::Internet.password }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    title { FFaker::Job.title }
  end

  factory :invited_user, class: User do
    email { FFaker::Internet.safe_email }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    title { FFaker::Job.title }
  end
end
