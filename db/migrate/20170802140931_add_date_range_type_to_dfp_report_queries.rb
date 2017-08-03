class AddDateRangeTypeToDfpReportQueries < ActiveRecord::Migration
  def change
    add_column :dfp_report_queries, :date_range_type, :integer, default: 0
  end
end
