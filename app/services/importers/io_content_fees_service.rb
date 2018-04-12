class Importers::IoContentFeesService < Importers::BaseService
  attr_accessor :content_fees, :ios

  def initialize(options = {})
    @content_fees = []
    @ios = []
    super(options)
  end

  def perform
    import
    content_fees.uniq.each {|content_fee| content_fee.update_budget}
    ios.uniq.each {|io| io.update_total_budget}
  end

  private

  def build_csv(row)
    Csv::IoContentFee.new(
      io_number: row[:io_number],
      product_name: row[:product],
      product_level1: row[:product_level1],
      product_level2: row[:product_level2],
      budget: row[:budget],
      start_date: row[:start_date],
      end_date: row[:end_date],
      company_id: company_id
    )
  end

  def after_import_row(csv_io_content_fee)
    content_fees << csv_io_content_fee.content_fee
    ios << csv_io_content_fee.io
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'IOContentFee'
  end

  def import_source
    'ui'
  end
end
