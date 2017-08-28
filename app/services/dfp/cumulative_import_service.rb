module DFP
  class CumulativeImportService < BaseImportService

    private

    def parse_dfp_report
      import_log = CsvImportLog.new(company_id: company_id, object_name: import_type)
      import_log.set_file_source(report_file)

      CSV.parse(report_csv, { headers: true, header_converters: :symbol }) do |row|
        import_to_temp_table(row)
      end
      duplicated_rows = []
      non_duplicated_rows = non_duplicate_items.map(&:attributes).map(&:symbolize_keys)
      duplicating_line_item_ids.each do |item_id|
        ser = DFP::TempCumulativeReportService.new(duplicating_line_item_id: item_id, company_id: company_id)
        merged_row = ser.get_merged_row
        duplicated_rows << merged_row
      end
      total_rows_arr = duplicated_rows + non_duplicated_rows
      total_rows_arr.each do |row|
        import_log.count_processed
        object_from_temp = import_temp_row(row)
        if object_from_temp.valid?
          begin
            object_from_temp.perform
            import_log.count_imported
          rescue Exception => e
            import_log.count_failed
            import_log.log_error ['Internal Server Error', row.to_h.compact.to_s]
            next
          end
        else
          import_log.count_failed
          import_log.log_error object_from_temp.errors.full_messages
        end
      end
      import_log.save
      destroy_temp_records
    end

    def duplicating_line_item_ids
      @duplicating_items ||= TempCumulativeDfpReport.duplicating_line_item_ids_by_company(company_id)
    end

    def non_duplicate_items
      @non_duplicate_rows ||= TempCumulativeDfpReport.where('company_id = ? AND dimensionline_item_id NOT IN (?)', company_id, duplicating_line_item_ids )
    end

    def import_to_temp_table(row)
      row_params = row.to_hash.merge(company_id: company_id)
      TempCumulativeDfpReport.create(row_params)
    end

    def destroy_temp_records
      TempCumulativeDfpReport.where(company_id: company_id).destroy_all
    end

    def import_temp_row(row)
      goal_quantity = adjustment_service.perform(row[:dimensionattributeline_item_goal_quantity]).to_i
      total_impressions = row[:columntotal_line_item_level_impressions].to_i

      if total_impressions >= goal_quantity
        total_impressions = goal_quantity
      end

      quantity_delivered = [ goal_quantity, total_impressions ].min
      price = row[:dimensionattributeline_item_cost_per_unit]
      non_cpd_booked_revenue = row[:dimensionattributeline_item_non_cpd_booked_revenue]
      budget_delivered = price * total_impressions / 1_000

      line_item_params = {
          io_name: row[:dimensionorder_name],
          io_advertiser: row[:dimensionadvertiser_name],
          io_agency: row[:dimensionattributeorder_agency],
          io_start_date: row[:dimensionattributeorder_start_date_time],
          io_end_date: row[:dimensionattributeorder_end_date_time],
          external_io_number: row[:dimensionorder_id].to_i,
          product_name: row[:dimensionline_item_name],
          product_id: row[:product_id],
          line_number: row[:dimensionline_item_id],
          ad_server: 'DFP',
          start_date: row[:dimensionattributeline_item_start_date_time],
          end_date: row[:dimensionattributeline_item_end_date_time],
          pricing_type: row[:dimensionattributeline_item_cost_type],
          price: price,
          quantity: goal_quantity,
          budget: adjustment_service.perform(non_cpd_booked_revenue),
          quantity_delivered: quantity_delivered,
          clicks: row[:columntotal_line_item_level_clicks],
          ctr: row[:columntotal_line_item_level_ctr],
          budget_delivered: budget_delivered,
          company_id: company_id,
          ad_unit_name: row[:dimensionad_unit_name]
      }

      if line_item_params[:pricing_type] == 'CPD'
        line_item_params[:budget] = price
        if line_item_params[:start_date].to_date < Date.today
          line_item_params[:budget_delivered] = price
        else
          line_item_params[:budget_delivered] = 0
        end

        line_item_params[:quantity] = total_impressions

        if line_item_params[:budget_delivered] > 0
          line_item_params[:quantity_delivered] = total_impressions
        end

      end
      DisplayLineItemCsv.new(line_item_params)
    end
  end
end
