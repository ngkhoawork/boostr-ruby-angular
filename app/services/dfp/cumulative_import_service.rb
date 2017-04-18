module DFP
  class CumulativeImportService < BaseImportService

    private

    def build_dli_csv(row)
      DisplayLineItemCsv.new(
        external_io_number: row[:dimensionorder_id],
        product_name: row[:dimensionline_item_name],
        line_number: row[:dimensionline_item_id],
        ad_server: 'DFP',
        start_date: row[:dimensionattributeline_item_start_date_time],
        end_date: row[:dimensionattributeline_item_end_date_time],
        pricing_type: row[:dimensionattributeline_item_cost_type],
        price: row[:dimensionattributeline_item_cost_per_unit],
        quantity: adjustment_service.perform(row[:dimensionattributeline_item_goal_quantity]),
        budget: row[:dimensionattributeline_item_non_cpd_booked_revenue],
        quantity_delivered: row[:columntotal_line_item_level_impressions],
        clicks: row[:columntotal_line_item_level_clicks],
        ctr: row[:columntotal_line_item_level_ctr],
        budget_delivered: row[:columntotal_line_item_level_all_revenue],

        company_id: company_id
      )
    end

    def adjustment_service
      @adjustment_service ||= DFP::CpmBudgetAdjustmentService.new(company_id: company_id)
    end
  end
end
