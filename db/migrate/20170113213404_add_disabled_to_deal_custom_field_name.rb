class AddDisabledToDealCustomFieldName < ActiveRecord::Migration
  def change
    add_column :deal_custom_field_names, :disabled, :boolean
  end
end
