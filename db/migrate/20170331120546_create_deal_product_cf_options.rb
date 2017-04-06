class CreateDealProductCfOptions < ActiveRecord::Migration
  def change
    create_table :deal_product_cf_options do |t|
      t.belongs_to :deal_product_cf_name, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
