class Csv::DealProductDecorator
  def initialize(deal_product, company)
    @deal_product = deal_product
    @deal = deal_product.deal
    @company = company
  end

  def deal_id
    deal.id
  end

  def deal_name
    deal.name
  end

  def advertiser
    deal.advertiser.name rescue nil
  end

  def agency
    deal.agency.name rescue nil
  end

  def deal_stage
    deal.stage.name rescue nil
  end

  def deal_probability
    deal.stage.probability rescue nil
  end

  def deal_start_date
    deal.start_date
  end

  def deal_end_date
    deal.end_date
  end

  def deal_currency
    deal.curr_cd 
  end

  def product_name
    deal_product.product.name rescue nil
  end

  def product_budget
    deal_product.budget_loc
  end

  def product_budget_usd
    deal_product.budget
  end

  def method_missing(name)
    cf_names = company.deal_product_cf_names
    deal_product_cf = cf_names.find_by(field_label: name.to_s.titleize) || cf_names.find_by(field_label: name.to_s)

    deal_product.deal_product_cf.send(deal_product_cf.field_name) if deal_product.deal_product_cf.present?
  end

  private

  attr_reader :deal_product, :deal, :company
end
