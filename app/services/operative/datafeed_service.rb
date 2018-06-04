class Operative::DatafeedService
  def initialize(api_config, date, intraday: false)
    @api_config = api_config
    @date = date
    @intraday = intraday
  end

  def perform
    get_files
    extract_and_verify
    import_sales_orders
    import_sales_order_line_items
    import_invoice_line_items
  rescue => e
    log_general_error(e, '')
  end

  private

  attr_reader :api_config, :datafeed_archive, :extracted_files, :date, :intraday

  def get_files
    file_service.perform
    if file_service.error.present?
      log_general_error(file_service.error, file_service.data_filename_local)
    else
      @datafeed_archive = file_service.data_filename_local
    end
  end

  def extract_and_verify
    return unless datafeed_archive
    @extracted_files = Operative::ExtractVerifyService.new(
      datafeed_archive, timestamp, intraday: intraday, hhmm: file_service.hhmm
    ).perform
  end

  def import_sales_orders
    return unless @extracted_files
    Operative::ImportSalesOrdersService.new(
      api_config,
      @extracted_files.slice(:sales_order, :currency)
    ).perform
  end

  def import_sales_order_line_items
    return unless @extracted_files
    Operative::ImportSalesOrderLineItemsService.new(
      api_config,
      @extracted_files.slice(:sales_order_line_items, :invoice_line_item)
    ).perform
  end

  def import_invoice_line_items
    return unless @extracted_files
    Operative::ImportInvoiceLineItemsService.new(
      api_config,
      @extracted_files.slice(:invoice_line_item, :invoice)
    ).perform
  end

  def timestamp
    date.strftime('%m%d%Y')
  end

  def log_general_error(error, file_source)
    import_log = CsvImportLog.new(company_id: api_config.company_id, object_name: 'io', source: 'operative')
    import_log.count_failed
    import_log.log_error(error)
    import_log.set_file_source(file_source)
    import_log.save
  end

  def file_service
    @file_service ||= Operative::GetFileService.new(api_config, timestamp, intraday: intraday)
  end
end
