module DFP
  class CumulativeImportService < BaseImportService

    private

    def build_csv(row)
      goal_quantity = adjustment_service.perform(row[:dimensionattributeline_item_goal_quantity]).to_i
      quantity_delivered = [
        goal_quantity,
        row[:columntotal_line_item_level_impressions].to_i
      ].min
      DisplayLineItemCsv.new(
        io_name: row[:dimensionorder_name],
        external_io_number: row[:dimensionorder_id].to_i,
        product_name: row[:dimensionline_item_name].to_i,
        line_number: row[:dimensionline_item_id],
        ad_server: 'DFP',
        start_date: row[:dimensionattributeline_item_start_date_time],
        end_date: row[:dimensionattributeline_item_end_date_time],
        pricing_type: row[:dimensionattributeline_item_cost_type],
        price: row[:dimensionattributeline_item_cost_per_unit].to_i,
        quantity: goal_quantity,
        budget: adjustment_service.perform(row[:dimensionattributeline_item_non_cpd_booked_revenue]).to_i,
        quantity_delivered: quantity_delivered,
        clicks: row[:columntotal_line_item_level_clicks],
        ctr: row[:columntotal_line_item_level_ctr],
        budget_delivered: row[:columnvideo_viewership_completion_rate].to_f * quantity_delivered,
        company_id: company_id
      )
    end
  end
end
