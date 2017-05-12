module DFP
  class CumulativeImportService < BaseImportService

    private

    def build_csv(row)
      goal_quantity = adjustment_service.perform(row[:dimensionattributeline_item_goal_quantity]).to_i
      quantity_delivered = [
        goal_quantity,
        row[:columntotal_line_item_level_impressions].to_i
      ].min
      rate = row[:columnvideo_viewership_completion_rate].to_f

      line_item_params = {
        io_name: row[:dimensionorder_name],
        io_advertiser: row[:dimensionadvertiser_name],
        io_agency: row[:dimensionattributeorder_agency],
        io_start_date: row[:dimensionattributeorder_start_date_time],
        io_end_date: row[:dimensionattributeorder_end_date_time],
        external_io_number: row[:dimensionorder_id].to_i,
        product_name: row[:dimensionline_item_name],
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
        budget_delivered: rate * quantity_delivered,
        company_id: company_id
      }

      if line_item_params[:pricing_type] == 'CPD'
        line_item_params[:budget] = rate

        if DateTime.parse(line_item_params[:start_date]).to_date < Date.today
          line_item_params[:budget_delivered] = rate
        else
          line_item_params[:budget_delivered] = 0
        end

        line_item_params[:quantity] = row[:columntotal_line_item_level_impressions].to_i

        if line_item_params[:budget_delivered] > 0
          line_item_params[:quantity_delivered] = row[:columntotal_line_item_level_impressions].to_i
        end

      end

      DisplayLineItemCsv.new(line_item_params)
    end
  end
end
