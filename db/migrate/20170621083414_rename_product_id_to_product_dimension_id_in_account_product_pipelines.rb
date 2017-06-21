class RenameProductIdToProductDimensionIdInAccountProductPipelines < ActiveRecord::Migration
  def change
    rename_column :account_product_pipeline_facts, :product_id, :product_dimension_id
  end
end
