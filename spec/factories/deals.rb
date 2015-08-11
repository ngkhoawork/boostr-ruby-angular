FactoryGirl.define do
  factory :deal do
    start_date Date.new(2015,7,29)
    end_date Date.new(2015,7,29)
    name 'MyString'
    stage
    next_steps 'Call Somebody'
    budget { rand(100_000..500_000) }
    deal_type ['Test Campaign',
               'Sponsorship',
               'Seasonal',
               'Renewal'].sample
    source_type ['Pitch to Client',
                 'Pitch to Agency',
                 'RFP Response to Client',
                 'RFP Response to Agency'].sample
    advertiser
  end
end
