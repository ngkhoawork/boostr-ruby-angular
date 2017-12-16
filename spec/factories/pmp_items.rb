FactoryGirl.define do
  factory :pmp_item do
    ssp_deal_id 'ssp-123'
    budget_loc 999
    association :pmp, factory: :pmp
    association :ssp, factory: :ssp
  end
end
