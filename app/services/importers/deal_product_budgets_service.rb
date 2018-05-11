class Importers::DealProductBudgetsService < Importers::BaseService
  attr_accessor :deal_products, :deals

  def initialize(options = {})
    @deal_products = []
    @deals = []
    super(options)
  end

  def perform
    import
    deal_products.uniq.each {|deal_product| deal_product.update_budget}
    deals.uniq.each {|deal| DealTotalBudgetUpdaterService.perform(deal)}
  end

  private

  def build_csv(row)
    Csv::DealProductBudget.new(
      deal_id: row[:deal_id],
      deal_name: row[:deal_name],
      product_name: row[:product],
      product_level1: row[:product_level1],
      product_level2: row[:product_level2],
      budget: row[:budget],
      start_date: row[:start_date],
      end_date: row[:end_date],
      company_id: company_id
    )
  end

  def after_import_row(csv_deal_product_budget)
    deal_products << csv_deal_product_budget.deal_product
    deals << csv_deal_product_budget.deal
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'DealProductBudget'
  end

  def import_source
    'ui'
  end
end
