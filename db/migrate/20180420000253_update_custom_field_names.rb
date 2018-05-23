class UpdateCustomFieldNames < ActiveRecord::Migration
  def up
    change_column :custom_field_names, :is_required, :boolean, default: false
    change_column :custom_field_names, :disabled, :boolean, default: false
    change_column :custom_field_names, :show_on_modal, :boolean, default: false

    CustomFieldName.where(is_required: nil).update_all(is_required: false)
    CustomFieldName.where(disabled: nil).update_all(disabled: false)
    CustomFieldName.where(show_on_modal: nil).update_all(show_on_modal: false)
  end

  def down
    change_column :custom_field_names, :is_required, :boolean, default: nil
    change_column :custom_field_names, :disabled, :boolean, default: nil
    change_column :custom_field_names, :show_on_modal, :boolean, default: nil
  end
end
