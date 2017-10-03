class CreateAccountProductPipelineFacts < ActiveRecord::Migration
  def change
    create_table :account_product_pipeline_facts do |t|
      t.references :product, index: true, foreign_key: true
      t.references :time_dimension, index: true, foreign_key: true
      t.references :account_dimension, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.decimal :weighted_amount
      t.decimal :unweighted_amount

      t.timestamps null: false
    end
  end
end
