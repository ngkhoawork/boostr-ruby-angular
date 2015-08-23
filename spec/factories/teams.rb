FactoryGirl.define do
  factory :parent_team, class: Team do
    sequence(:name) { |n| "Team #{n}" }
  end

  factory :child_team, class: Team do
    association :parent, factory: :parent_team
    sequence(:name) { |n| "Child Team #{n}" }
  end
end
