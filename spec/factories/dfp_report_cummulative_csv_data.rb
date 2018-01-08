FactoryBot.define do
  factory :dfp_report_cummulative_csv_data, class: Hash do
    dimensionorder_name "Hershey test_301"
    dimensionadvertiser_name "Hershey"
    dimensionline_item_name "Hershey test - In-Feed - :30 - iOS"
    dimensionorder_id "605084194"
    dimensionadvertiser_id "942655594"
    dimensionline_item_id "1170022354"
    dimensionattributeorder_start_date_time "2016-10-28T12:42:00-07:00"
    dimensionattributeorder_end_date_time "2016-11-27T23:59:00-08:00"
    dimensionattributeorder_agency "-"
    dimensionattributeline_item_start_date_time "2016-10-31T00:00:00-07:00"
    dimensionattributeline_item_end_date_time "2016-11-27T23:59:00-08:00"
    dimensionattributeline_item_cost_type "CPM"
    dimensionattributeline_item_cost_per_unit "20000000"
    dimensionattributeline_item_goal_quantity "85000"
    dimensionattributeline_item_non_cpd_booked_revenue "1700000000"
    columntotal_line_item_level_impressions "85001"
    columntotal_line_item_level_clicks "977"
    columntotal_line_item_level_all_revenue "1700020000"
    columntotal_line_item_level_ctr "0.0115"
    columnvideo_viewership_average_view_rate "0.1677"
    columnvideo_viewership_completion_rate "0.5998"

    initialize_with { attributes }
  end
end
