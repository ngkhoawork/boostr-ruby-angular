FactoryGirl.define do
  factory :client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
    address

    before(:create) do |item|
      item.company = Company.first

      if item.client_type_id.nil?
        item.client_type_id = Company.first.fields.find_by(name: 'Client Type').options.ids.sample
      end
    end
  end
end
