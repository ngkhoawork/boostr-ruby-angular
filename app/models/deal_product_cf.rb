class DealProductCf < ActiveRecord::Base
  include HasValidationsOnPercentageCfs

  belongs_to :company
  belongs_to :deal_product


  before_save :fetch_company_id_from_deal, on: :create

  after_update do
    calculate_sum
  end

  after_create do
    calculate_sum
  end

  after_destroy do
    calculate_sum
  end

  def deal_product_cf_names
    @deal_product_cf_names ||= deal_product&.deal&.company&.deal_product_cf_names || DealProductCfName.none
  end

  def calculate_sum
    deal = self.deal_product.deal

    total1 = 0
    total2 = 0
    total3 = 0
    total4 = 0
    total5 = 0
    total6 = 0
    total7 = 0
    deal_custom_field = deal.deal_custom_field
    deal_custom_field = DealCustomField.new(deal_id: deal.id) if deal_custom_field.nil?
    deal.deal_products.each do |deal_product|
      total1 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum1 || 0)
      total2 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum2 || 0)
      total3 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum3 || 0)
      total4 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum4 || 0)
      total5 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum5 || 0)
      total6 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum6 || 0)
      total7 += deal_product.deal_product_cf.nil? ? 0 : (deal_product.deal_product_cf.sum7 || 0)
    end
    deal_custom_field.sum1 = total1
    deal_custom_field.sum2 = total2
    deal_custom_field.sum3 = total3
    deal_custom_field.sum4 = total4
    deal_custom_field.sum5 = total5
    deal_custom_field.sum6 = total6
    deal_custom_field.sum7 = total7
    deal_custom_field.save
  end

  private

  def self.custom_field_names_assoc
    :deal_product_cf_names
  end

  def fetch_company_id_from_deal
    self.company_id ||= deal_product.deal&.company_id
  end
end
