class CreateBpEstimates < ActiveRecord::Migration
  def change
    create_table :bp_estimates do |t|
      t.belongs_to :bp, index: true, foreign_key: true
      t.belongs_to :client, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.float :estimate_seller
      t.float :estimate_mgr
      t.string :objectives
      t.string :assumptions

      t.timestamps null: false
    end
  end
end
