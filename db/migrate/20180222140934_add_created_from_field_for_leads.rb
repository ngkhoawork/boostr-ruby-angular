class AddCreatedFromFieldForLeads < ActiveRecord::Migration
  def change
    add_column :leads, :created_from, :string
  end
end
