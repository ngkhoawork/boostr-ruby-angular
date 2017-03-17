class Operative::DatafeedService
  def initialize(api_config)
    @api_config = api_config
  end

  def perform
    get_files
    extract_and_verify
    import_sales_orders
    process_sales_order_line_items
  end

  private
  attr_reader :api_config, :datafeed_archive, :extracted_files

  def get_files
    @datafeed_archive = Operative::GetFileService.new(api_config).perform
  end

  def extract_and_verify
    @extracted_files = Operative::ExtractVerifyService.new(datafeed_archive).perform
  end

  def import_sales_orders
    Operative::ImportSalesOrdersService.new(
      api_config.company_id,
      @extracted_files.slice(:sales_order, :currency)
    ).perform
  end

  def process_sales_order_line_items
    Operative::ImportSalesOrderLineItemsService.new(
      api_config.company_id,
      @extracted_files.slice(:sales_order_line_items, :invoice_line_item, :currency)
    ).perform
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
