FactoryGirl.define do
  factory :notification do
    company_id 1
    name "MyString"
    subject "MyString"
    message "MyText"
    active false
    recipients "MyText"
  end
end
