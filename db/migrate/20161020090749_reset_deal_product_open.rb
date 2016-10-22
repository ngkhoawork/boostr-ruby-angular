class ResetDealProductOpen < ActiveRecord::Migration
  def change
    DealProduct.update_all(open: true)
  end
end
