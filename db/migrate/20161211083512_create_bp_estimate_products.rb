class CreateBpEstimateProducts < ActiveRecord::Migration
  def change
    create_table :bp_estimate_products do |t|
      t.belongs_to :bp_estimate, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.float :estimate_seller
      t.float :estimate_mgr

      t.timestamps null: false
    end
  end
end
