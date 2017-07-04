class ExtendTempReportIntegerType < ActiveRecord::Migration
  def up
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_cost_per_unit, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_goal_quantity, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_non_cpd_booked_revenue, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_impressions, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_clicks, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_all_revenue, :integer, limit: 8
  end

  def down
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_cost_per_unit, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_goal_quantity, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_non_cpd_booked_revenue, :integer
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_impressions, :integer
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_clicks, :integer
    change_column :temp_cumulative_dfp_reports, :columntotal_line_item_level_all_revenue, :integer
  end
end
