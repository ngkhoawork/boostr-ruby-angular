FactoryBot.define do
  factory :bp_estimate do
    bp nil
    client nil
    user nil
    estimate_seller 1.5
    estimate_mgr 1.5
    objectives "MyString"
    assumptions "MyString"
  end
end
