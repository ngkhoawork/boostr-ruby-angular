FactoryGirl.define do
  factory :address do
    street1 { FFaker::AddressUS.street_address }
    street2 { FFaker::Address.secondary_address }
    city { FFaker::AddressUS.city }
    state { FFaker::AddressUS.state_abbr }
    zip { FFaker::AddressUS.zip_code }
    phone { FFaker::PhoneNumber.phone_number }
    mobile { FFaker::PhoneNumber.phone_number }
  end
end
