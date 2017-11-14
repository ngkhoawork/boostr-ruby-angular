class AddShowBillingContactToEalerts < ActiveRecord::Migration
  def change
    add_column :ealerts, :show_billing_contact, :boolean, default: false
  end
end
