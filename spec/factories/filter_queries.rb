FactoryGirl.define do
  factory :filter_query do
    name 'MyString'
    query_type 'Pipeline Summary'
    filter_params { { user_id: 1, team_id: 2 } }
  end
end
