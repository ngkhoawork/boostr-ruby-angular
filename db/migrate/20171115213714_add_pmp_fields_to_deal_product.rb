class AddPmpFieldsToDealProduct < ActiveRecord::Migration
  def change
    add_reference :deal_products, :ssp, foreign_key: true
    add_column :deal_products, :is_guaranteed, :boolean
    add_column :deal_products, :ssp_deal_id, :string
  end
end
