class Csv::DealProductDecorator
  def initialize(deal_product, company, deal_product_cf_labels)
    @deal_product = deal_product
    @deal = deal_product.deal
    @company = company
    @deal_product_cf_labels = deal_product_cf_labels
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
    deal_product.product.level0.[]('name') rescue nil
  end

  def product_budget
    deal_product.budget_loc
  end

  def product_budget_usd
    deal_product.budget
  end

  def method_missing(name)
    check_product_options(name) || check_custom_fields(name)
  end

  private

  def check_custom_fields(name)
    cf_names = company.deal_product_cf_names
    field_label = deal_product_cf_labels.select { |label| name.eql?(parameterize(label)) }.first
    deal_product_cf = cf_names.find_by(field_label: field_label)

    if deal_product.deal_product_cf.present? && deal_product_cf.present?
      deal_product.deal_product_cf.send(deal_product_cf.field_name)
    end
  end

  def check_product_options(name)
    if company.product_options_enabled && name.eql?(product_option1)
      deal_product.product&.level1&.[]('name')
    elsif company.product_options_enabled && name.eql?(product_option2)
      deal_product.product&.level2&.[]('name')
    end
  end

  def parameterize(name)
    Csv::BaseService.parameterize(name).to_sym
  end

  def product_option1
    parameterize(company.product_option1)
  end

  def product_option2
    parameterize(company.product_option2)
  end

  attr_reader :deal_product, :deal, :company, :deal_product_cf_labels
end
