FactoryGirl.define do
  factory :value do

    before(:create) do |item|
      item.company ||= Company.first
    end
  end
end
