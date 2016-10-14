class UpdateOpenInDealProduct < ActiveRecord::Migration
  def change
    deals = Deal.with_deleted
    deals.each do |deal|
      deal.deal_products.update_all(open: (deal.stage.probability != 100))
    end
  end
end
