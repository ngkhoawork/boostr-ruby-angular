class DFP::CumulativeImportService
  def initialize(company_id, files)
    @company_id = company_id
    @report_file = files.fetch(:report_file)
  end

  def perform
    @report_csv = open_file(report_file)
    if @report_csv
      parse_dfp_report
    end
  end

  private
  attr_reader :company_id, :report_file, :report_csv

  def open_file(file)
    begin
      File.open(file, 'r:ISO-8859-1')
    rescue Exception => e
      puts e
      import_log = CsvImportLog.new(company_id: company_id, object_name: 'dfp_cumulative')
      import_log.set_file_source(file)
      import_log.log_error [e.class.to_s, e.message]
      import_log.save
    end
  end

  def parse_dfp_report
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'dfp_cumulative')
    import_log.set_file_source(report_file)

    CSV.parse(report_csv, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed
      dli_csv = build_dli_csv(row)

      if dli_csv.valid?
        begin
          dli_csv.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s]
          next
        end
      else
        import_log.count_failed
        import_log.log_error dli_csv.errors.full_messages
      end
    end

    import_log.save
  end

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
      quantity: row[:dimensionattributeline_item_goal_quantity],
      budget: row[:dimensionattributeline_item_non_cpd_booked_revenue],
      quantity_delivered: row[:columntotal_line_item_level_impressions],
      clicks: row[:columntotal_line_item_level_clicks],
      ctr: row[:columntotal_line_item_level_ctr],
      budget_delivered: row[:columntotal_line_item_level_all_revenue],

      company_id: company_id
    )
  end
end
