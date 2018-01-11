class AddDateFiedldsToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :accepted_at, :datetime
    add_column :leads, :rejected_at, :datetime
    add_column :leads, :reassigned_at, :datetime
    add_column :leads, :contact_id, :integer
    add_index :leads, :contact_id
  end
end
