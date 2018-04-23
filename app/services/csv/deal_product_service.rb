class Csv::DealProductService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::DealProductDecorator.new(record, company, deal_product_cf_labels) }
  end

  def headers
    deal_product_cf_names.blank? ? basic_headers : basic_headers.push(deal_product_cf_labels).flatten
  end

  def basic_headers
    headers = [
      'Deal_id',
      'Deal_name',
      'Advertiser',
      'Agency',
      'Deal_stage',
      'Deal_probability',
      'Deal_start_date',
      'Deal_end_date',
      'Deal_currency',
      'Product_name'
    ]
    if company.product_options_enabled
      headers << company.product_option1 if company.product_option1_enabled
      headers << company.product_option2 if company.product_option2_enabled
    end
    headers + [
      'Product_budget',
      'Product_budget_USD'
    ]
  end

  def deal_product_cf_names
    @_deal_product_cf_names ||= company.deal_product_cf_names
  end

  def deal_product_cf_labels
    @_deal_product_cf_labels ||= deal_product_cf_names.map(&:field_label)
  end
end
