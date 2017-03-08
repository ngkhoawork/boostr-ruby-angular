FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
    address

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end

    factory :contact_with_clients do
      transient do
        clients_count 1
      end


      after(:create) do |contact, evaluator|
        create_list(:client, evaluator.clients_count, contacts: [contact])
      end
    end
  end
end
