module DFP
  class CumulativeImportService < BaseImportService

    def perform
      super
      set_report_file
      import_from_temp_table
      destroy_temp_records
    end

    private

    def parse_dfp_report
      row_number = 0
      CSV.parse(report_csv, { headers: true, header_converters: :symbol }) do |row|
        row_number += 1
        import_to_temp_table(row: row, source_file_row_number: row_number)
      end
    end

    def import_from_temp_table
      rows_from_temp_table.each do |row|
        csv_import_log.count_processed
        object_from_temp = import_temp_row(row)
        if object_from_temp.valid?
          begin
            object_from_temp.perform
            csv_import_log.count_imported
          rescue Exception => e
            csv_import_log.count_failed
            csv_import_log.log_error e.message, row[:source_file_row_number].to_s
            next
          end
        else
          csv_import_log.count_failed
          csv_import_log.log_error object_from_temp.errors.full_messages, row[:source_file_row_number].to_s
        end
      end
      csv_import_log.save
    end

    def set_report_file
      csv_import_log.set_file_source(report_file)
    end

    def rows_from_temp_table
      duplicating_rows + non_duplicated_rows
    end

    def csv_import_log
      @csv_import_log ||= CsvImportLog.new(company_id: company_id, object_name: import_type)
    end

    def non_duplicated_rows
      non_duplicate_items.map(&:attributes).map(&:symbolize_keys)
    end

    def duplicating_rows
      duplicating_line_item_ids.each_with_object([]) do |item_id, duplicated_rows|
        duplicated_rows << temp_cumulative_service(item_id, company_id).get_merged_row
      end
    end

    def temp_cumulative_service(item_id, company_id)
      DFP::TempCumulativeReportService.new(duplicating_line_item_id: item_id, company_id: company_id)
    end

    def duplicating_line_item_ids
      @duplicating_items ||= TempCumulativeDfpReport.duplicating_line_item_ids_by_company(company_id)
    end

    def non_duplicate_items
      @non_duplicate_rows ||= if duplicating_line_item_ids.any?
                                TempCumulativeDfpReport.where('company_id = :company_id AND dimensionline_item_id NOT IN (:ids)',
                                                              company_id: company_id,
                                                              ids: duplicating_line_item_ids)
                              else
                                TempCumulativeDfpReport.where('company_id = :company_id',
                                                              company_id: company_id)
                              end
    end

    def import_to_temp_table(params = {})
      return if params.blank?
      row_params = params[:row].to_hash.merge(company_id: company_id, source_file_row_number: params[:source_file_row_number])
      TempCumulativeDfpReport.create!(row_params)
    end

    def destroy_temp_records
      TempCumulativeDfpReport.where(company_id: company_id).delete_all
    end

    def import_temp_row(row)
      goal_quantity = adjustment_service.perform(row[:dimensionattributeline_item_goal_quantity]).to_i
      total_impressions = row[:columntotal_line_item_level_impressions].to_i

      if total_impressions >= goal_quantity
        total_impressions = goal_quantity
      end

      quantity_delivered = [goal_quantity, total_impressions].min
      price = row[:dimensionattributeline_item_cost_per_unit]
      budget_delivered = price * total_impressions / 1_000
      budget = row[:dimensionattributeline_item_goal_quantity] * 0.001 * price / adjustment_service.cpm_budget_adjustment_factor_reversed

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
          budget: budget,
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
