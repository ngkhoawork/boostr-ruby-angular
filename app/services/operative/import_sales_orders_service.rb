class Operative::ImportSalesOrdersService
  def initialize(company_id, files)
    @company_id = company_id
    @sales_order = files[:sales_order]
    @currency = files[:currency]
  end

  def perform
    @sales_order_file = open_file(@sales_order)
    @currency_file = open_file(@currency)
    if @sales_order_file && @currency_file
      parse_and_process_rows
    end
  end

  private
  attr_reader :company_id, :sales_order, :sales_order_file, :currency, :currency_file, :currencies_list

  def open_file(file)
    begin
      File.open(file, 'r:ISO-8859-1')
    rescue Exception => e
      import_log = CsvImportLog.new(company_id: company_id, object_name: 'io', source: 'operative')
      import_log.set_file_source(file)
      import_log.log_error [e.class.to_s, e.message]
      import_log.save
    end
  end

  def parse_and_process_rows
    parse_currencies
    parse_sales_order
  end

  def parse_currencies
    @currencies_list = {}
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'currency', source: 'operative')
    import_log.set_file_source(currency)

    File.foreach(currency_file).with_index do |line, line_num|
      if line_num == 0
        @currency_headers = CSV.parse_line(line)
        next
      end

      begin
        row = CSV.parse_line(line.force_encoding("ISO-8859-1").encode("UTF-8"), headers: @currency_headers, header_converters: :symbol)
      rescue Exception => e
        import_log.count_failed
        import_log.log_error [e.message, line]
        next
      end

      currency_id = row[:currency_id]
      currency_code = row[:currency_code]
      @currencies_list[currency_id] = currency_code
    end

    import_log.save if import_log.is_error?
  end

  def parse_sales_order
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'io', source: 'operative')
    import_log.set_file_source(sales_order)

    File.foreach(sales_order_file).with_index do |line, line_num|
      if line_num == 0
        @headers = CSV.parse_line(line)
        next
      end

      import_log.count_processed

      begin
        row = CSV.parse_line(line.force_encoding("ISO-8859-1").encode("UTF-8"), headers: @headers, header_converters: :symbol)
      rescue Exception => e
        import_log.count_failed
        import_log.log_error [e.message, line]
        next
      end

      if irrelevant_order(row)
        import_log.count_skipped
        next
      end
      io_csv = build_io_csv(row)
      if io_csv.valid?
        begin
          io_csv.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ['Internal Server Error', row.to_h.compact.to_s]
          next
        end
      else
        import_log.count_failed
        import_log.log_error io_csv.errors.full_messages
        next
      end
    end

    import_log.save
  end

  def irrelevant_order(row)
    row[:sales_stage_percent] != '100' || row[:order_status].try(:downcase) == 'deleted'
  end

  def build_io_csv(row)
    IoCsv.new(
      io_external_number: row[:sales_order_id],
      io_name: row[:sales_order_name],
      io_start_date: row[:order_start_date],
      io_end_date: row[:order_end_date],
      io_advertiser: row[:advertiser_name],
      io_agency: row[:agency_name],
      io_budget: row[:total_order_value],
      io_budget_loc: row[:total_order_value],
      io_curr_cd: get_curr_cd(row[:order_currency_id]),
      company_id: company_id
    )
  end

  def get_curr_cd(curr_id)
    @currencies_list[curr_id]
  end
end
