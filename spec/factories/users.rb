FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.disposable_email }
    password { FFaker::Internet.password }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    title { FFaker::Job.title }
    default_currency 'USD'

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
      create(:currency) if Currency.find_by(curr_cd: 'USD').blank?
    end
  end

  factory :invited_user, class: User do
    email { FFaker::Internet.disposable_email }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    title { FFaker::Job.title }

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
