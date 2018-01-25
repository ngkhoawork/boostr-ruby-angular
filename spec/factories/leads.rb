FactoryGirl.define do
  factory :lead do
    first_name 'Joe'
    last_name 'Doe'
    title 'Mr'
    email 'joe_doe@gmail.com'
    company_name 'Apple'
    country 'USA'
    state 'NY'
    budget 10_000
    notes 'Please asap'
  end
end
