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
    replace_team 'N'
    team nil
    created '01/01/2016'
    closed_date '02/02/2016'
    close_reason nil
    contacts nil
    loss_comments nil
    next_step nil
    created_by nil
    legacy_id { FFaker::HipsterIpsum.word }

    initialize_with { attributes }

    after(:build) do |item|
      setup_default_deal_csv_data(item)
    end

    factory :deal_csv_data_custom_fields do
      after(:build) do |item|
        setup_custom_fields(item)
      end
    end
  end
end

def setup_default_deal_csv_data(item)
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

def setup_custom_fields(item)
  item[:custom_field_names].each do |cf|
    item[cf.to_csv_header] = case cf.field_type
    when 'boolean'
      [true, false].sample
    when 'datetime'
      FFaker::Time.date
    when 'number'
      max = 999
      min = 100
      (rand * (max - min) + min).round(2)
    when 'text'
      FFaker::BaconIpsum.paragraph
    end
  end
  item[:custom_field_names] = nil
end
