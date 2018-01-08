FactoryBot.define do
  factory :dfp_report_monthly_csv_data, class: Hash do
    dimensionorder_id '1234'
    dimensionline_item_id '4321'
    dimensionmonth_and_year '2017-03'
    columntotal_line_item_level_clicks '1000'
    columntotal_line_item_level_ctr '0.0192'
    columntotal_line_item_level_impressions '10000'
    columnvideo_viewership_average_view_rate '0.0120'
    columnvideo_viewership_completion_rate '0.0034'

    initialize_with { attributes }
  end
end
