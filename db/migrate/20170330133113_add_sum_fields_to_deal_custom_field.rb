class AddSumFieldsToDealCustomField < ActiveRecord::Migration
  def change
    add_column :deal_custom_fields, :sum1, :integer
    add_column :deal_custom_fields, :sum2, :integer
    add_column :deal_custom_fields, :sum3, :integer
    add_column :deal_custom_fields, :sum4, :integer
    add_column :deal_custom_fields, :sum5, :integer
    add_column :deal_custom_fields, :sum6, :integer
    add_column :deal_custom_fields, :sum7, :integer
  end
end
