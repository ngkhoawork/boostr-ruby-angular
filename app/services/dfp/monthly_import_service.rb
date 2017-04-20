module DFP
  class MonthlyImportService < BaseImportService

    private

    def build_csv(row)
      DisplayLineItemBudgetCsv.new(
        external_io_number: row[:dimensionorder_id],
        line_number: row[:dimensionline_item_id],
        month_and_year: row[:dimensionmonth_and_year],
        clicks: row[:columntotal_line_item_level_clicks],
        ctr: row[:columntotal_line_item_level_ctr],
        impressions: row[:columntotal_line_item_level_impressions],
        budget_loc: adjustment_service.perform(row[:columntotal_line_item_level_impressions]),
        video_avg_view_rate: row[:columnvideo_viewership_average_view_rate],
        video_completion_rate: row[:columnvideo_viewership_completion_rate],
        company_id: company_id
      )
    end
  end
end
