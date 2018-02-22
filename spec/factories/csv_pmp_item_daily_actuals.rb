FactoryGirl.define do
  factory :csv_pmp_item_daily_actual, class: Csv::PmpItemDailyActual do
    date '5/5/2017'
    price 999.99
    revenue_loc 999.99
    impressions 99
    ad_requests 99
    ad_unit 'ad'
    company

    after(:build) do |csv_pmp_item_daily_actual|
      if csv_pmp_item_daily_actual.ssp_deal_id.blank?
        pmp_item = FactoryGirl.create :pmp_item
        csv_pmp_item_daily_actual.ssp_deal_id = pmp_item.ssp_deal_id
      end
    end
  end
end
