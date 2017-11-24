FactoryGirl.define do
  factory :client_csv do
    company_id nil
    name { FFaker::Company.name }
    type { %w{advertiser agency}.sample }
    parent_account nil
    category nil
    teammembers nil
    region nil
    segment nil
    holding_company nil

    # io_external_number { rand(1000..9999) }
    # io_name { FFaker::Product.product_name }
    # io_start_date { FFaker::Time.date }
    # io_end_date { FFaker::Time.date }
    # io_advertiser { FFaker::Company.name }
    # io_agency { FFaker::Company.name }
    # io_budget { rand(1000..9999) }
    # io_budget_loc { rand(1000..9999) }
    # io_curr_cd 'USD'
  end
end
