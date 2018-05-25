FactoryGirl.define do
  factory :spend_agreement do
    name "MyText"
    start_date "2017-12-05"
    end_date "2017-12-05"
    target 1_000.00
    company_id nil
    holding_company
    manually_tracked false
    client_ids []
    parent_companies_ids []
    publishers_ids []

    before(:create) do |item|
      item.company ||= Company.first
    end
  end
end
