FactoryBot.define do
  factory :filter_query do
    sequence(:name) { |n| "Filter Query #{n}" }
    query_type 'pipeline_summary_report'
    filter_params '{user_id: 1, team_id: 2}'
  end
end
