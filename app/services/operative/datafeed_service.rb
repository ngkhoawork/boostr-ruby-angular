class Operative::DatafeedService
  def initialize(config)
    @company = Company.find config.company_id
    @auth_details = {
      company_name: @company.name,
      login: config.api_email,
      password: config.password,
      host: config.base_link
    }
  end

  # TODO LIMIT TO ONE COMPANY
  def perform
    get_files
    extract_and_verify
    import_sales_orders
    process_sales_order_line_items
  end

  private
  attr_reader :auth_details, :datafeed_archive, :extracted_files

  def get_files
    @datafeed_archive = Operative::GetFileService.new(auth_details).perform
  end

  def extract_and_verify
    @extracted_files = Operative::ExtractVerifyService.new(datafeed_archive).perform
  end

  def import_sales_orders
    Operative::ImportSalesOrdersService.new(
      company.id,
      @extracted_files.slice(:sales_order, :currency)
    ).perform
  end

  def process_sales_order_line_items
    Operative::ImportSalesOrderLineItemsService.new(
      company.id,
      @extracted_files.slice(:sales_order_line_item, :invoice_line_item, :currency)
    ).perform
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
