class Operative::ImportInvoiceLineItemsService
  def initialize(api_config, files)
    @api_config = api_config
    @files = files
    @invoice_line_items = files.fetch(:invoice_line_item)
    @invoices = files.fetch(:invoice)
  end

  def perform
    self.class.define_calculator_method(revenue_calculation_pattern)
    parse_invoices
    parse_invoice_lines
  end

  private

  attr_reader :api_config, :files

  delegate :company_id, :revenue_calculation_pattern, :skip_not_changed?, to: :api_config

  def open_file(file_label)
    file = files.fetch file_label

    begin
      File.open(file, 'r:ISO-8859-1')
    rescue Exception => e
      import_log = CsvImportLog.new(company_id: company_id, object_name: 'invoice_line_item', source: 'operative')
      import_log.set_file_source(file)
      import_log.log_error [e.class.to_s, e.message]
      import_log.save
    end
  end

  def parse_invoices
    @parsed_invoices ||= {}

    File.foreach(open_file(:invoice)).with_index do |line, line_num|
      if line_num == 0
        @headers = CSV.parse_line(line)
        next
      end

      begin
        row = csv_parse_line(line)
      rescue Exception => e
        next
      end

      @parsed_invoices[row[:invoice_id]] = row[:billing_period_name]
    end
  end

  def parse_invoice_lines
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'display_line_item_budget', source: 'operative')
    file = open_file(:invoice_line_item)
    import_log.set_file_source(file)
    last_import_date = skip_not_changed? ? import_log.last_import_date : -Float::INFINITY

    File.foreach(file).with_index do |line, line_num|
      import_log.count_processed

      if line_num == 0
        @headers = CSV.parse_line(line)
        next
      end

      begin
        row = csv_parse_line(line)
      rescue Exception => e
        import_log.count_failed
        import_log.log_error [e.message, line]
        next
      end

      if irrelevant_row(row, last_import_date)
        import_log.count_skipped
        next
      end

      line_item_budget_csv = build_line_item_budget_csv(row)

      if line_item_budget_csv.irrelevant?
        import_log.count_skipped
        next
      end

      if line_item_budget_csv.valid?
        begin
          line_item_budget_csv.perform
          import_log.count_imported
        rescue Exception => e
          import_log.count_failed
          import_log.log_error ["invoice_line_item_id: #{row[:invoice_line_item_id]}", e.message]
          next
        end
      else
        import_log.count_failed
        import_log.log_error ["invoice_line_item_id: #{row[:invoice_line_item_id]}", line_item_budget_csv.errors.full_messages]
      end
    end

    import_log.save
  end

  def irrelevant_row(row, last_import_date)
    last_modified_date(row[:last_modified_on]) < last_import_date
  end

  def last_modified_date(date)
    date&.to_date || Date.today
  end

  def amend_quotes(line)
    line.gsub(/(?<!\,)(\")(?![,\r\n])/, "\"\"")
  end

  def csv_parse_line(line)
    begin
      CSV.parse_line(line.force_encoding("ISO-8859-1").encode("UTF-8"), headers: @headers, header_converters: :symbol)
    rescue CSV::MalformedCSVError => e
      CSV.parse_line(amend_quotes(line).force_encoding("ISO-8859-1").encode("UTF-8"), headers: @headers, header_converters: :symbol)
    end
  end

  def build_line_item_budget_csv(row)
    DisplayLineItemBudgetCsvOperative.new(
      invoice_id: row[:invoice_id],
      line_number: row[:sales_order_line_item_id],
      budget_loc: recognized_revenue_calculator(row),
      month_and_year: @parsed_invoices[row[:invoice_id]],
      impressions: row[:invoice_units],
      revenue_calculation_pattern: revenue_calculation_pattern,
      company_id: company_id
    )
  end

  def self.define_calculator_method(pattern)
    case DatafeedConfigurationDetails.get_pattern_name(pattern)
    when 'Invoice Units'
      define_method(:recognized_revenue_calculator) do |line_item|
        line_item[:invoice_units].to_f / 1000
      end
    when 'Recognized Revenue'
      define_method(:recognized_revenue_calculator) do |line_item|
        line_item[:recognized_revenue].to_f + line_item[:recognized_revenue_adjustment].to_f
      end
    when 'Invoice Amount'
      define_method(:recognized_revenue_calculator) do |line_item|
        line_item[:invoice_amount].to_f
      end
    end
  end
end
