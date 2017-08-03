class ExtendTempCumulativeDfpReportIntegers < ActiveRecord::Migration
  def up
    change_column :temp_cumulative_dfp_reports, :dimensionline_item_id, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :dimensionadvertiser_id, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :dimensionad_unit_id, :integer, limit: 8
    change_column :temp_cumulative_dfp_reports, :dimensionorder_id, :integer, limit: 8
  end

  def down
    change_column :temp_cumulative_dfp_reports, :dimensionline_item_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionadvertiser_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionad_unit_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionorder_id, :integer
  end
end
