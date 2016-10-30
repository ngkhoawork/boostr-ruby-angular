class RenamePricingTypeToRevenueType < ActiveRecord::Migration
  def change
    rename_column :products, :pricing_type, :revenue_type
  end
end
