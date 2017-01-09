class AddRequiredToFieldName < ActiveRecord::Migration
  def change
    add_column :deal_custom_field_names, :is_required, :boolean
    add_column :deal_custom_field_names, :position, :integer
  end
end
