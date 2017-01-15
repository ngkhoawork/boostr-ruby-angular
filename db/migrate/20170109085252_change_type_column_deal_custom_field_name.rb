class ChangeTypeColumnDealCustomFieldName < ActiveRecord::Migration
  def change
    rename_column :deal_custom_field_names, :type, :field_type
    rename_column :deal_custom_field_names, :label, :field_label
  end
end
