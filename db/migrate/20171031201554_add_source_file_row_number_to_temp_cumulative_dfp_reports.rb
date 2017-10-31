class AddSourceFileRowNumberToTempCumulativeDfpReports < ActiveRecord::Migration
  def change
    add_column :temp_cumulative_dfp_reports, :source_file_row_number, :bigint
  end
end
