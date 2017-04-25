class AddClosedReasonTextToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :closed_reason_text, :string
  end
end
