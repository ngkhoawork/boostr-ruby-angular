class ChangeWeightedUnweightedFieldType < ActiveRecord::Migration
  def change
    change_column :account_product_pipeline_facts, :weighted_amount, :integer
    change_column :account_product_pipeline_facts, :unweighted_amount, :integer
  end
end
