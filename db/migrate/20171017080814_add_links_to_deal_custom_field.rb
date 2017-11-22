class AddLinksToDealCustomField < ActiveRecord::Migration
  def change
    add_column :deal_custom_fields, :link2, :string
    add_column :deal_custom_fields, :link3, :string
    add_column :deal_custom_fields, :link4, :string
    add_column :deal_custom_fields, :link5, :string
    add_column :deal_custom_fields, :link6, :string
    add_column :deal_custom_fields, :link7, :string
  end
end
