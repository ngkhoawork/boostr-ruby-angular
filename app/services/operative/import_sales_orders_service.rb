class Operative::ImportSalesOrdersService
  def initialize(sales_order)
    @sales_order = sales_order
  end

  def perform
    @sales_order_file = open_file
    parse_and_process_rows
  end

  private
  attr_reader :sales_order, :sales_order_file

  def open_file
    File.open(sales_order, 'r:ISO-8859-1')
  end

  def parse_and_process_rows
    CSV.parse(sales_order_file, { headers: true, header_converters: :symbol }) do |row|
      sales_order = IoCsv.new(
        io_external_number: row[:sales_order_id],
        io_name: row[:sales_order_name],
        io_start_date: row[:order_start_date],
        io_end_date: row[:order_end_date],
        io_advertiser: row[:advertiser_name],
        io_agency: row[:agency_name],
        io_budget: row[:total_order_value],
        io_budget_loc: row[:total_order_value],
        io_curr_cd: row[:order_currency_id]
      )
      sales_order.perform
    end
  end
end
