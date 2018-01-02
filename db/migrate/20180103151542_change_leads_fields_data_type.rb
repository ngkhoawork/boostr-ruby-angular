class ChangeLeadsFieldsDataType < ActiveRecord::Migration
  def change
    change_column :leads, :budget, :string
    change_column :leads, :notes, :text
  end
end
