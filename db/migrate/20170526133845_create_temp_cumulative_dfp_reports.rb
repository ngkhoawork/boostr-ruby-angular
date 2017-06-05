class CreateTempCumulativeDfpReports < ActiveRecord::Migration
  def change
    create_table :temp_cumulative_dfp_reports do |t|
      t.string :dimensionorder_name
      t.string :dimensionadvertiser_name
      t.string :dimensionline_item_name
      t.string :dimensionad_unit_name
      t.integer :dimensionorder_id
      t.integer :dimensionadvertiser_id
      t.integer :dimensionline_item_id
      t.integer :dimensionad_unit_id
      t.datetime :dimensionattributeorder_start_date_time
      t.datetime :dimensionattributeorder_end_date_time
      t.string :dimensionattributeorder_agency
      t.datetime :dimensionattributeline_item_start_date_time
      t.datetime :dimensionattributeline_item_end_date_time
      t.string :dimensionattributeline_item_cost_type
      t.integer :dimensionattributeline_item_cost_per_unit
      t.integer :dimensionattributeline_item_goal_quantity
      t.integer :dimensionattributeline_item_non_cpd_booked_revenue
      t.integer :columntotal_line_item_level_impressions
      t.integer :columntotal_line_item_level_clicks
      t.integer :columntotal_line_item_level_all_revenue
      t.float :columntotal_line_item_level_ctr
      t.float :columnvideo_viewership_average_view_rate
      t.float :columnvideo_viewership_completion_rate
      t.integer :company_id

      t.timestamps null: true
    end
  end
end