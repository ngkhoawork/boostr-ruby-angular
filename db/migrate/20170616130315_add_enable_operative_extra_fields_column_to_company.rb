class AddEnableOperativeExtraFieldsColumnToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :enable_operative_extra_fields, :boolean, default: false
  end
end
