class Operative::ImportSalesOrderLineItemsService
  def initialize(company_id, revenue_calculation_pattern, product_mapping, exclude_child_line_items, files)
    @company_id = company_id
    @revenue_calculation_pattern = revenue_calculation_pattern
    @product_mapping = product_mapping
    @exclude_child_line_items = exclude_child_line_items
    @sales_order_line_items = files.fetch(:sales_order_line_items)
    @invoice_line_items = files.fetch(:invoice_line_item)
  end

  def perform
    @sales_order_csv_file = open_file(sales_order_line_items)
    @invoice_csv_file = open_file(invoice_line_items)
    if @sales_order_csv_file && @invoice_csv_file
      self.class.define_calculator_method(@revenue_calculation_pattern)
      self.class.define_product_mapping(@product_mapping)
      parse_invoices
      parse_line_items
    end
  end

  private
  attr_reader :company_id, :revenue_calculation_pattern, :sales_order_line_items,
              :invoice_line_items, :invoice_csv_file, :sales_order_csv_file, :invoice_csv_file,
              :exclude_child_line_items

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
    @parsed_invoices ||= {}

    File.foreach(invoice_csv_file).with_index do |line, line_num|
      if line_num == 0
        @invoice_headers = CSV.parse_line(line)
        next
      end

      begin
        row = CSV.parse_line(line.force_encoding("ISO-8859-1").encode("UTF-8"), headers: @invoice_headers, header_converters: :symbol)
      rescue Exception => e
        next
      end

      @parsed_invoices[row[:sales_order_line_item_id]] ||= []
      @parsed_invoices[row[:sales_order_line_item_id]] << {
        invoice_units: row[:invoice_units],
        cumulative_primary_performance: row[:cumulative_primary_performance],
        cumulative_third_party_performance: row[:cumulative_third_party_performance],
        recognized_revenue: row[:recognized_revenue],
        invoice_amount: row[:invoice_amount]
      }
    end
  end

  def parse_line_items
    import_log = CsvImportLog.new(company_id: company_id, object_name: 'display_line_item', source: 'operative')
    import_log.set_file_source(sales_order_line_items)

    File.foreach(sales_order_csv_file).with_index do |line, line_num|
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
      product_name: product_mapping(row),
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
    parent_line_item_presence(row[:parent_line_item_id]) ||
    !row[:quantity].present? ||
    !row[:net_cost].present? ||
    row[:net_cost].to_f.zero?
  end

  def parent_line_item_presence(parent_line_item_id)
    if exclude_child_line_items
      parent_line_item_id.present?
    else
      false
    end
  end

  def find_in_invoices(id, net_unit_cost)
    lines = @parsed_invoices[id]

    if lines.nil?
      return {
        sales_order_line_item_id:           id,
        recognized_revenue:                 0.0,
        cumulative_primary_performance:     0,
        cumulative_third_party_performance: 0
      }
    end

    recognized_revenue = recognized_revenue_calculator(lines, net_unit_cost)

    {
      sales_order_line_item_id:           id,
      recognized_revenue:                 recognized_revenue,
      cumulative_primary_performance:     lines[-1][:cumulative_primary_performance].to_i,
      cumulative_third_party_performance: lines[-1][:cumulative_third_party_performance].to_i
    }
  end

  def self.define_calculator_method(pattern)
    case DatafeedConfigurationDetails.get_pattern_name(pattern)
    when 'Invoice Units'
      define_method(:recognized_revenue_calculator) do |lines, net_unit_cost|
        lines.map { |row| row[:invoice_units].to_f      }.reduce(0, :+) / 1000 * net_unit_cost.to_f
      end
    when 'Recognized Revenue'
      define_method(:recognized_revenue_calculator) do |lines, net_unit_cost|
        lines.map { |row| row[:recognized_revenue].to_f }.reduce(0, :+)
      end
    when 'Invoice Amount'
      define_method(:recognized_revenue_calculator) do |lines, net_unit_cost|
        lines.map { |row| row[:invoice_amount].to_f     }.reduce(0, :+)
      end
    end
  end

  def self.define_product_mapping(mapping)
    case DatafeedConfigurationDetails.get_product_mapping_name(mapping)
    when 'Product_Name'
      define_method(:product_mapping) do |row|
        row[:product_name]
      end
    when 'Forecast_Category'
      define_method(:product_mapping) do |row|
        row[:forecast_category]
      end
    end
  end
end
