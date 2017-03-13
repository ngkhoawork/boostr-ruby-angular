class Operative::ImportSalesOrderLineItemsService
  def initialize(company_id, sales_order_line_items, invoice_line_items)
    @company_id = company_id
    @sales_order_line_items = sales_order_line_items
    @invoice_line_items = invoice_line_items
  end

  def perform
    @sales_order_csv_file = open_file(sales_order_line_items)
    @invoice_csv_file = open_file(invoice_line_items)
    parse_invoices
    parse_line_items
  end

  private
  attr_reader :company_id, :sales_order_line_items, :invoice_line_items, :invoice_csv_file, :sales_order_csv_file, :invoice_csv_file

  def open_file(file)
    File.open(file, 'r:ISO-8859-1')
  end

  def parse_invoices
    @_parsed_invoices ||= []
    CSV.parse(invoice_csv_file, { headers: true, header_converters: :symbol }) do |row|
      @_parsed_invoices << {
        sales_order_line_item_id: row[:sales_order_line_item_id],
        recognized_revenue: row[:recognized_revenue],
        cumulative_primary_performance: row[:cumulative_primary_performance],
        cumulative_third_party_performance: row[:cumulative_third_party_performance]
      }
    end
  end

  def parse_line_items
    CSV.parse(sales_order_csv_file, { headers: true, header_converters: :symbol }) do |row|
      invoice = find_in_invoices(row[:sales_order_line_item_id])
      sales_order_line_item = DisplayLineItemCsv.new(
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
      sales_order_line_item.perform
    end
  end

  def find_in_invoices(id)
    @_parsed_invoices.find(-> { {} }) do |invoice|
      invoice[:sales_order_line_item_id] == id
    end
  end
end
