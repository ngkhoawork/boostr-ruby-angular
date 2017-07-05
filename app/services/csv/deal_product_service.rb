class Csv::DealProductService < Csv::BaseService
  def initialize(company, records)
    @company = company
    @records = records
  end

  private

  attr_reader :company

  def decorated_records
    records.map { |record| Csv::DealProductDecorator.new(record, company) }
  end

  def headers
    deal_product_cf_names.blank? ? basic_headers : basic_headers.push(deal_product_cf_names.map(&:field_label)).flatten
  end

  def basic_headers
    %w(
      Deal_id Deal_name Advertiser Agency Deal_stage Deal_probability Deal_start_date Deal_end_date Deal_currency
      Product_name Product_budget Product_budget_USD
    )
  end
  
  def deal_product_cf_names
    @_deal_product_cf_names ||= company.deal_product_cf_names
  end
end
