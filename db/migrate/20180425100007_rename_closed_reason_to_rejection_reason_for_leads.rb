class RenameClosedReasonToRejectionReasonForLeads < ActiveRecord::Migration
  def change
    rename_column :leads, :closed_reason, :rejected_reason
  end
end
