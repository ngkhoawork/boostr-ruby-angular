FactoryGirl.define do
  factory :deal do
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    sequence(:name) { |n| "Deal #{n}" }
    stage
    next_steps 'Call Somebody'
    deal_type ['Test Campaign',
               'Sponsorship',
               'Seasonal',
               'Renewal'].sample
    source_type ['Pitch to Client',
                 'Pitch to Agency',
                 'RFP Response to Client',
                 'RFP Response to Agency'].sample
    advertiser
    agency
  end
end
