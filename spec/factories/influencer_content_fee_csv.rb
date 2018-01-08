FactoryBot.define do
  factory :influencer_content_fee_csv, class: Csv::InfluencerContentFee do
    io_number { rand(1000..9999) }
    influencer_id { rand(1000..9999) }
    product_name { FFaker::Product.product_name }
    date { FFaker::Time.date }
    fee_type 'percentage'
    fee_amount { rand(1000..9999) }
    gross_amount_loc { rand(1000..9999) }
    asset { FFaker::Company.name }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
