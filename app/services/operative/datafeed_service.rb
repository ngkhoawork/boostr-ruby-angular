class Operative::DatafeedService
  def initialize(api_config, date)
    @api_config = api_config
    @date = date
  end

  def perform
    get_files
    extract_and_verify
    import_sales_orders
    process_sales_order_line_items
  end

  private
  attr_reader :api_config, :datafeed_archive, :extracted_files, :date

  def get_files
    file_service = Operative::GetFileService.new(api_config, timestamp)
    file_service.perform
    if file_service.error.present?
      log_general_error(file_service)
    else
      @datafeed_archive = file_service.data_filename_local
    end
  end

  def extract_and_verify
    return unless datafeed_archive
    @extracted_files = Operative::ExtractVerifyService.new(datafeed_archive, timestamp).perform
  end

  def import_sales_orders
    return unless @extracted_files
    Operative::ImportSalesOrdersService.new(
      api_config.company_id,
      api_config.auto_close_deals,
      @extracted_files.slice(:sales_order, :currency)
    ).perform
  end

  def process_sales_order_line_items
    return unless @extracted_files
    Operative::ImportSalesOrderLineItemsService.new(
      api_config.company_id,
      @extracted_files.slice(:sales_order_line_items, :invoice_line_item, :currency)
    ).perform
  end

  def timestamp
    date.strftime('%m%d%Y')
  end

  def log_general_error(file_service)
    import_log = CsvImportLog.new(company_id: api_config.company_id, object_name: 'io', source: 'operative')
    import_log.count_failed
    import_log.log_error(file_service.error)
    import_log.set_file_source(file_service.data_filename_local)
    import_log.save
  end
end
