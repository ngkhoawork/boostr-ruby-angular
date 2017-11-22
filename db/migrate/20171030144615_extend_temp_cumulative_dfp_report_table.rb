class ExtendTempCumulativeDfpReportTable < ActiveRecord::Migration
  def up
    change_column :temp_cumulative_dfp_reports, :dimensionorder_id, :bigint
    change_column :temp_cumulative_dfp_reports, :dimensionadvertiser_id, :bigint
    change_column :temp_cumulative_dfp_reports, :dimensionline_item_id, :bigint
    change_column :temp_cumulative_dfp_reports, :dimensionad_unit_id, :bigint
  end

  def down
    change_column :temp_cumulative_dfp_reports, :dimensionorder_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionadvertiser_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionline_item_id, :integer
    change_column :temp_cumulative_dfp_reports, :dimensionad_unit_id, :integer
  end
end