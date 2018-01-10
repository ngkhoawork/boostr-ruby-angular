FactoryGirl.define do
  factory :user do
    email { rand(999999).to_s + FFaker::Internet.email }
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

  factory :admin, parent: :user do
    after(:create) do |item|
      item.add_role('admin')
    end
  end
end
