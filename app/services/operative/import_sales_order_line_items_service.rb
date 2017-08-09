class Operative::ImportSalesOrderLineItemsService
  def initialize(company_id, files)
    @company_id = company_id
    @sales_order_line_items = files.fetch(:sales_order_line_items)
    @invoice_line_items = files.fetch(:invoice_line_item)
  end

  def perform
    @sales_order_csv_file = open_file(sales_order_line_items)
    @invoice_csv_file = open_file(invoice_line_items)
    if @sales_order_csv_file && @invoice_csv_file
      parse_invoices
      parse_line_items
    end
  end

  private
  attr_reader :company_id, :sales_order_line_items, :invoice_line_items, :invoice_csv_file, :sales_order_csv_file, :invoice_csv_file

  def open_file(file)
    begin
      File.open(file, 'r:ISO-8859-1')
    rescue Exception => e
      import_log = CsvImportLog.new(company_id: company_id, object_name: 'display_line_item', source: 'operative')
      import_log.set_file_source(file)
      import_log.log_error [e.class.to_s, e.message]
      import_log.save
    end
  end

  def parse_invoices
    @_parsed_invoices ||= []
    CSV.parse(invoice_csv_file, { headers: true, header_converters: :symbol }) do |row|
      @_parsed_invoices << {
        sales_order_line_item_id: row[:sales_order_line_item_id],
        invoice_units: row[:invoice_units],
        cumulative_primary_performance: row[:cumulative_primary_performance],
        cumulative_third_party_performance: row[:cumulative_third_party_performance]
      }
    end
  end

  def parse_line_items
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'display_line_item', source: 'operative')
    import_log.set_file_source(sales_order_line_items)

    CSV.parse(sales_order_csv_file, { headers: true, header_converters: :symbol }) do |row|
      import_log.count_processed

      if irrelevant_line_item(row)
        import_log.count_skipped
        next
      end
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
    invoice = find_in_invoices(row[:sales_order_line_item_id], row[:net_unit_cost])
    DisplayLineItemCsv.new(
      external_io_number: row[:sales_order_id],
      line_number: row[:sales_order_line_item_id],
      ad_server: 'O1',
      start_date: row[:sales_order_line_item_start_date],
      end_date: row[:sales_order_line_item_end_date],
      product_name: row[:product_name],
      quantity: row[:quantity],
      price: row[:net_unit_cost],
      pricing_type: row[:cost_type],
      budget: row[:net_cost],
      budget_delivered: invoice[:recognized_revenue],
      quantity_delivered: invoice[:cumulative_primary_performance],
      quantity_delivered_3p: invoice[:cumulative_third_party_performance],
      company_id: company_id
    )
  end

  def irrelevant_line_item(row)
    row[:line_item_status].try(:downcase) != 'sent_to_production' ||
    !row[:quantity].present? ||
    !row[:net_cost].present?
  end

  def find_in_invoices(id, net_unit_cost)
    lines = @_parsed_invoices.select do |invoice|
      invoice[:sales_order_line_item_id] == id
    end

    if lines.empty?
      return {
        sales_order_line_item_id:           id,
        recognized_revenue:                 0.0,
        cumulative_primary_performance:     0,
        cumulative_third_party_performance: 0
      }
    end

    recognized_revenue = lines.map {|row| row[:invoice_units].to_f}.reduce(0, :+) / 1000 * net_unit_cost.to_f

    {
      sales_order_line_item_id:           id,
      recognized_revenue:                 recognized_revenue,
      cumulative_primary_performance:     lines[-1][:cumulative_primary_performance].to_i,
      cumulative_third_party_performance: lines[-1][:cumulative_third_party_performance].to_i
    }
  end
end
