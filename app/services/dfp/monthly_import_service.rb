module DFP
  class MonthlyImportService < BaseImportService

    private

    def build_csv(row)
      DisplayLineItemBudgetCsvDfp.new(
        io_name: row[:dimensionorder_name],
        external_io_number: row[:dimensionorder_id],
        line_number: row[:dimensionline_item_id],
        month_and_year: row[:dimensionmonth_and_year],
        clicks: row[:columntotal_line_item_level_clicks],
        ctr: row[:columntotal_line_item_level_ctr],
        impressions: row[:columntotal_line_item_level_impressions].to_i,
        budget_loc: row[:columntotal_line_item_level_impressions].to_i,
        video_avg_view_rate: row[:columnvideo_viewership_average_view_rate],
        video_completion_rate: row[:columnvideo_viewership_completion_rate],
        company_id: company_id
      )
    end
  end
end
