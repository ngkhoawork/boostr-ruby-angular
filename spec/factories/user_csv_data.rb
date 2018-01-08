FactoryBot.define do
  factory :user_csv_data, class: Hash do
    email FFaker::Internet.email
    name 'First Name'
    title 'Ms.'
    currency 'USD'
    user_type 'account manager'
    revenue_requests false
    employee_id '45623'
    office 'Toronto'
    team ''
    is_admin true
    status 'active'

    initialize_with { attributes }
  end
end
