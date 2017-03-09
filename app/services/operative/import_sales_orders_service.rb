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
    Transforms::SalesOrderTransform.new(sales_order_file).transform
  end
end
