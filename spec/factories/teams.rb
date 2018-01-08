FactoryBot.define do
  factory :team do
    name { FFaker::HipsterIpsum.word }
    company
  end

  factory :parent_team, class: Team do
    sequence(:name) { |n| "Team #{n}" }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end

  factory :child_team, class: Team do
    association :parent, factory: :parent_team
    sequence(:name) { |n| "Child Team #{n}" }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
