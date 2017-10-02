class RenameProductIdToProductDimensionIdInAccountProductRevenue < ActiveRecord::Migration
  def up
    rename_column :account_product_revenue_facts, :product_id, :product_dimension_id
  end

  def down
    rename_column :account_product_revenue_facts, :product_dimension_id, :product_id
  end
end
