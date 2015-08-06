FactoryGirl.define do
  factory :deal do
    start_date '2015-07-29 12:52:56'
    end_date '2015-07-29 12:52:56'
    name 'MyString'
    stage
    budget { rand(100_000..500_000) }
    deal_type ['Test Campaign',
               'Sponsorship',
               'Seasonal',
               'Renewal'].sample
    source_type ['Pitch to Client',
                 'Pitch to Agency',
                 'RFP Response to Client',
                 'RFP Response to Agency'].sample
  end
end
