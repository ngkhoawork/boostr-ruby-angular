class AddReopenedAtToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :reopened_at, :datetime
  end
end
