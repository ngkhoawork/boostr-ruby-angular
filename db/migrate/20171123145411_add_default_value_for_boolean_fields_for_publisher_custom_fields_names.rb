class AddDefaultValueForBooleanFieldsForPublisherCustomFieldsNames < ActiveRecord::Migration
  def up
    change_column_default :publisher_custom_field_names, :is_required, false
    change_column_default :publisher_custom_field_names, :show_on_modal, false
    change_column_default :publisher_custom_field_names, :disabled, false
  end

  def down
    change_column_default :publisher_custom_field_names, :is_required, nil
    change_column_default :publisher_custom_field_names, :show_on_modal, nil
    change_column_default :publisher_custom_field_names, :disabled, nil
  end
end
