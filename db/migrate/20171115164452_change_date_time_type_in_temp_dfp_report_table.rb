class ChangeDateTimeTypeInTempDfpReportTable < ActiveRecord::Migration
  def up
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_start_date_time, :date
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_end_date_time, :date
    change_column :temp_cumulative_dfp_reports, :dimensionattributeorder_start_date_time, :date
    change_column :temp_cumulative_dfp_reports, :dimensionattributeorder_end_date_time, :date
  end

  def down
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_start_date_time, :datetime
    change_column :temp_cumulative_dfp_reports, :dimensionattributeline_item_end_date_time, :datetime
    change_column :temp_cumulative_dfp_reports, :dimensionattributeorder_start_date_time, :datetime
    change_column :temp_cumulative_dfp_reports, :dimensionattributeorder_end_date_time, :datetime
  end
end
