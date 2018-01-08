FactoryBot.define do
  factory :dfp_report_query do
    report_type 1
weekly_recurrence_day 1
monthly_recurrence_day 1
is_daily_recurrent false
dfp_api_configuration nil
  end

end
