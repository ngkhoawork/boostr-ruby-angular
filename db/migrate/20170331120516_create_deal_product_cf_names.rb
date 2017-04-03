class CreateDealProductCfNames < ActiveRecord::Migration
  def change
    create_table :deal_product_cf_names do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.integer :field_index
      t.string :field_type
      t.string :field_label
      t.boolean :is_required
      t.integer :position
      t.boolean :show_on_modal
      t.boolean :disabled

      t.timestamps null: false
    end
  end
end
