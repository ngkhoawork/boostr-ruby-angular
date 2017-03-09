class Operative::DatafeedService
  def initialize(company_id)
    @company = Company.find company_id
    @auth_details = {
      company_name: @company.name,
      login: 'fs_king.u',
      password: 'hVmSKJfJ0YzA7w==',
      host: 'ftpprod.operativeone.com'
    }
  end

  # TODO LIMIT TO ONE COMPANY
  def perform
    @datafeed_files = get_files
    @extracted_files = extract_and_verify
    import_sales_orders
    # process_sales_order_line_items
  end

  private
  attr_reader :auth_details, :datafeed_files, :extracted_files

  def get_files
    Operative::GetFileService.new(auth_details).perform
  end

  def extract_and_verify
    Operative::ExtractVerifyService.new(datafeed_files).perform
  end

  def import_sales_orders
    Operative::ImportSalesOrdersService.new(@extracted_files.find { |f| f == "./datafeed/Sales_Order_#{timestamp}.csv" }).perform
  end

  def process_sales_order_line_items
    
  end

  def timestamp
    # Date.today.strftime('%m%d%Y')
    '03052017'
  end
end
