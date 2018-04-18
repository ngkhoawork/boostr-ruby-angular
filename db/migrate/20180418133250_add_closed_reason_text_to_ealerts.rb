class AddClosedReasonTextToEalerts < ActiveRecord::Migration
  def change
    add_column :ealerts, :closed_reason_text, :integer, limit: 2, default: 0
  end
end
