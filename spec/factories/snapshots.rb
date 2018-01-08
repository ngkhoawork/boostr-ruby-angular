FactoryBot.define do
  factory :snapshot do
    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
