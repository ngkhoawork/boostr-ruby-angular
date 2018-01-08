FactoryBot.define do
  factory :notification do
    company
    name "MyString"
    subject "MyString"
    message "MyText"
    active false
    recipients "MyText"
  end
end
