class DealProductCf < ActiveRecord::Base
  belongs_to :company
  belongs_to :deal_product

  after_update do
    calculate_sum
  end

  def calculate_sum
    deal = self.deal_product.deal

    if (self.sum1_changed? || self.sum2_changed? || self.sum3_changed? || self.sum4_changed? || self.sum5_changed? || self.sum6_changed? || self.sum7_changed?)
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
        total1 += (deal_product.deal_product_cf.sum1 || 0)
        total2 += (deal_product.deal_product_cf.sum2 || 0)
        total3 += (deal_product.deal_product_cf.sum3 || 0)
        total4 += (deal_product.deal_product_cf.sum4 || 0)
        total5 += (deal_product.deal_product_cf.sum5 || 0)
        total6 += (deal_product.deal_product_cf.sum6 || 0)
        total7 += (deal_product.deal_product_cf.sum7 || 0)
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
  end

end
