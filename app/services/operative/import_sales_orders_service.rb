class Operative::ImportSalesOrdersService
  def initialize(company_id, files)
    @company_id = company_id
    @sales_order = files.fetch(:sales_order)
    @currency = files.fetch(:currency)
  end

  def perform
    @sales_order_file = open_file(@sales_order)
    @currency_file = open_file(@currency)
    parse_and_process_rows
  end

  private
  attr_reader :company_id, :sales_order, :sales_order_file, :currency, :currency_file, :currencies_list

  def open_file(file)
    File.open(file, 'r:ISO-8859-1')
  end

  def parse_and_process_rows
    parse_currencies
    parse_sales_order
  end

  def parse_currencies
    @currencies_list = {}
    CSV.parse(currency_file, { headers: true, header_converters: :symbol }) do |row|
      currency_id = row[:currency_id]
      currency_code = row[:currency_code]
      @currencies_list[currency_id] = currency_code
    end
  end

  def parse_sales_order
    CSV.parse(sales_order_file, { headers: true, header_converters: :symbol }) do |row|
      if irrelevant_order(row)
        next
      end
      sales_order = create_sales_order(row)
      if sales_order.valid?
        sales_order.perform
      else
        next
      end
    end
  end

  def irrelevant_order(row)
    row[:sales_stage_percent] != '100' || row[:order_status] == 'deleted'
  end

  def create_sales_order(row)
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
