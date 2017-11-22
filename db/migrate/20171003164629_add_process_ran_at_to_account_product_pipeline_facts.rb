class AddProcessRanAtToAccountProductPipelineFacts < ActiveRecord::Migration
  def change
    add_column :account_product_pipeline_facts, :process_ran_at, :datetime
  end
end
