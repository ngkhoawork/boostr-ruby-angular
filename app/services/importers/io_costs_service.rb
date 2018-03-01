class Importers::IoCostsService < Importers::BaseService
  attr_accessor :costs

  def initialize(options = {})
    @costs = []
    super(options)
  end

  def perform
    import
    costs.uniq.each { |cost| cost.update_budget }
  end

  private

  def build_csv(row)
    Csv::IoCost.new(
      io_number: row[:io_number],
      product_name: row[:product],
      type: row[:type],
      month: row[:month],
      amount: row[:amount],
      company_id: company_id
    )
  end

  def after_import_row(csv_io_cost)
    costs << csv_io_cost.cost
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'IOCost'
  end

  def import_source
    'ui'
  end
end