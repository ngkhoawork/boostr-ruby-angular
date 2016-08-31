FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
    address

    transient do
      clients_count 1
    end

    before(:create) do |item|
      item.company = Company.first
    end

    after(:create) do |contact, evaluator|
      create_list(:client, evaluator.clients_count, contacts: [contact])
    end
  end
end
