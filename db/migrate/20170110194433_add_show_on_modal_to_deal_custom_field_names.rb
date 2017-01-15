class AddShowOnModalToDealCustomFieldNames < ActiveRecord::Migration
  def change
    add_column :deal_custom_field_names, :show_on_modal, :boolean
  end
end
