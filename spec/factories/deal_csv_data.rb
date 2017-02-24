FactoryGirl.define do
  factory :deal_csv_data, class: Hash do
    id nil
    name { FFaker::NatoAlphabet.callsign }
    advertiser nil
    agency nil
    curr_cd 'USD'
    type nil
    source nil
    start_date '01/01/2016'
    end_date '02/02/2016'
    stage nil
    team nil
    created '01/01/2016'
    closed_date '02/02/2016'
    close_reason nil
    contacts nil

    initialize_with { attributes }

    after(:build) do |item|
      if item[:advertiser].nil?
        item[:advertiser] = Company.first.clients.order(:id).second.name
      end

      if item[:agency].nil?
        item[:agency] = Company.first.clients.order(:id).fourth.name
      end

      if item[:curr_cd].nil?
        item[:curr_cd] = 'USD'
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