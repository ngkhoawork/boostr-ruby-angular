class RefactorDealProduct < ActiveRecord::Migration
  def change
    add_column :deal_products, :open, :boolean, default: true
    remove_column :deal_products, :period
  end
end
