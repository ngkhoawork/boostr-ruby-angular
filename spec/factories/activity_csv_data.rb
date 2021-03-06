FactoryGirl.define do
  factory :activity_csv_data, class: Hash do
    id nil
    date '01/01/2016'
    creator nil
    advertiser nil
    agency nil
    deal nil
    type nil
    comment { FFaker::HipsterIpsum.phrase }
    contacts nil

    initialize_with { attributes }

    after(:build) do |item|
      item[:company] ||= Company.first

      if item[:creator].nil?
        item[:creator] = item[:company].users.first.email
      end

      if item[:type].nil?
        item[:type] = item[:company].activity_types.sample.name
      end

      if item[:deal].nil?
        item[:deal] = Deal.where(name: 'New Big Deal').first.name
      end

      if item[:contacts].nil?
        item[:contacts] = item[:company].contacts.map(&:address).map(&:email).join(';')
      end
    end
  end
end
