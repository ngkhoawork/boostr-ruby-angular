FactoryBot.define do
  factory :temp_cumulative_dfp_report do
    dimensionorder_name "MyString"
    dimensionadvertiser_name "MyString"
    dimensionline_item_name "MyString"
    dimensionad_unit_name "MyString"
    dimensionorder_id "MyString"
    dimensionadvertiser_id 1
    dimensionline_item_id 1
    dimensionad_unit_id 1
    dimensionattributeorder_start_date_time Date.today
    dimensionattributeorder_end_date_time Date.today + 3.days
    dimensionattributeorder_agency "MyString"
    dimensionattributeline_item_start_date_time Date.today
    dimensionattributeline_item_end_date_time Date.today + 3.days
    dimensionattributeline_item_cost_type "MyString"
    dimensionattributeline_item_cost_per_unit 100
    dimensionattributeline_item_goal_quantity 3000
    dimensionattributeline_item_non_cpd_booked_revenue 2500
    columntotal_line_item_level_impressions 3000
    columntotal_line_item_level_clicks 2000
    columntotal_line_item_level_all_revenue 1000
    columntotal_line_item_level_ctr 0.02
    columnvideo_viewership_average_view_rate 0.02
    columnvideo_viewership_completion_rate 1.5
  end
end
