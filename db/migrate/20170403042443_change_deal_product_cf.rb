class ChangeDealProductCf < ActiveRecord::Migration
  def change
    remove_reference :deal_product_cfs, :deal
    add_reference :deal_product_cfs, :deal_product
  end
end
