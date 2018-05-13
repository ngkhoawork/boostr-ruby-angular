class DFP::BaseImportService
  def initialize(company_id, import_type, files)
    @company_id = company_id
    @import_type = import_type
    @report_file = files.fetch(:report_file)
    @report_csv = open_file report_file
  end

  def perform
    parse_dfp_report if @report_csv
  end

  private

  attr_reader :company_id, :report_file, :report_csv, :import_type

  def open_file(file)
    begin
      File.open(file, 'r:ISO-8859-1')
    rescue Exception => e
      puts e
      import_log = CsvImportLog.new(company_id: company_id, object_name: import_type, source: 'dfp')
      import_log.set_file_source(file)
      import_log.log_error [e.class.to_s, e.message]
      import_log.save
    end
  end

  def parse_dfp_report
    import_log = CsvImportLog.new(company_id: company_id, object_name: import_type, source: 'dfp')
    import_log.set_file_source(report_file)

    CSV.parse(report_csv, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed
      object_from_csv = build_csv(row)

      if object_from_csv.valid?
        begin
          object_from_csv.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s]
          next
        end
      else
        import_log.count_failed
        import_log.log_error object_from_csv.errors.full_messages
      end
    end
    import_log.save
  end

  def adjustment_service
    @adjustment_service ||= DFP::CpmBudgetAdjustmentService.new(company_id: company_id)
  end
end
