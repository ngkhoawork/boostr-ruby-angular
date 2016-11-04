FactoryGirl.define do
  factory :deal_csv_data, class: Hash do
    id nil
    name { FFaker::NatoAlphabet.callsign }
    advertiser nil
    agency nil
    type nil
    source nil
    start_date '2016-01-01 00:00:00 +0200'
    end_date '2016-02-02 00:00:00 +0200'
    stage nil
    team nil
    created '2016-01-01 00:00:00 +0200'
    closed_date '2016-02-02 00:00:00 +0200'
    close_reason nil
    contacts nil

    initialize_with { attributes }

    after(:build) do |item|
      if item[:advertiser].nil?
        item[:advertiser] = Company.first.clients.order(:id).first.name
      end

      if item[:agency].nil?
        item[:agency] = Company.first.clients.order(:id).second.name
      end

      if item[:stage].nil?
        item[:stage] = Company.first.stages.sample.name
      end

      if item[:team].nil?
        user = Company.first.users.first
        item[:team] = user.email + '/100'
      end

      if item[:contacts].nil?
        item[:contacts] = Company.first.contacts.map(&:address).map(&:email).join(';')
      end
    end
  end
end