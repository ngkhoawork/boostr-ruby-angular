class AddDropDownFieldsToDealCustomField < ActiveRecord::Migration
  def change
  	add_column :deal_custom_fields, :dropdown1, :string
  	add_column :deal_custom_fields, :dropdown2, :string
  	add_column :deal_custom_fields, :dropdown3, :string
  	add_column :deal_custom_fields, :dropdown4, :string
  	add_column :deal_custom_fields, :dropdown5, :string
  	add_column :deal_custom_fields, :dropdown6, :string
  	add_column :deal_custom_fields, :dropdown7, :string

  end
end
