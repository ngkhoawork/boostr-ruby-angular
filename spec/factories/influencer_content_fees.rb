FactoryGirl.define do
  factory :influencer_content_fee do
    influencer nil
		content_fee nil
		fee_type "MyString"
		curr_cd "MyString"
		gross_amount "9.99"
		gross_amount_loc "9.99"
		net "9.99"
		asset "MyText"
  end
end
