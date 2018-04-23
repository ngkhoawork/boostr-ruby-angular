class RemoveReopenedAtColumnFromLeads < ActiveRecord::Migration
  def change
    remove_column :leads, :reopened_at, :datetime
  end
end
