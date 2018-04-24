class AddClosedReasonToLead < ActiveRecord::Migration
  def change
    add_column :leads, :closed_reason, :string
  end
end
