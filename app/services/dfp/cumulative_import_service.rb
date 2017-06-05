module DFP
  class CumulativeImportService < BaseImportService

    private

    def parse_dfp_report
      import_log = CsvImportLog.new(company_id: company_id, object_name: import_type)
      import_log.set_file_source(report_file)

      CSV.parse(report_csv, { headers: true, header_converters: :symbol }) do |row|
        import_to_temp_table(row)
        duplicating_line_item_ids.each do |item_id|
          ser = DFP::TempCumulativeReportService.new(duplicating_line_item_id: item_id, company_id: company_id)
          merged_row = ser.get_merged_row
        end
        destroy_temp_records
      end
    end

    def duplicating_line_item_ids
      @duplicating_items ||= TempCumulativeDfpReport.duplicating_line_item_ids_by_company(company_id)
    end

    def non_duplicate_items
      @non_duplicate_rows ||= TempCumulativeDfpReport.where.not(dimensionline_item_id: duplicating_line_item_ids)
    end

    def import_to_temp_table(row)
      row_params = row.to_hash.merge(company_id: company_id)
      TempCumulativeDfpReport.create(row_params)
    end

    def destroy_temp_records
      TempCumulativeDfpReport.where(company_id: company_id).destroy_all
    end

    def build_csv(row)
      import_to_temp(row)
    end
  end
end
