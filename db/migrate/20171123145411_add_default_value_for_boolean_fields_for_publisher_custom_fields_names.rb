class AddDefaultValueForBooleanFieldsForPublisherCustomFieldsNames < ActiveRecord::Migration
  def change
    change_column_default :publisher_custom_field_names, :is_required, false
    change_column_default :publisher_custom_field_names, :show_on_modal, false
    change_column_default :publisher_custom_field_names, :disabled, false
  end
end
