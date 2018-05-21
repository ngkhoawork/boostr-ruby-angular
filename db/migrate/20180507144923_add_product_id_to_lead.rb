class AddProductIdToLead < ActiveRecord::Migration
  def change
    add_column :leads, :product_id, :integer, index: true
  end
end
