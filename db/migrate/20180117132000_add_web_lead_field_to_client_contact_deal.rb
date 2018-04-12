class AddWebLeadFieldToClientContactDeal < ActiveRecord::Migration
  def change
    add_column :clients, :web_lead, :boolean, default: false
    add_column :contacts, :web_lead, :boolean, default: false
    add_column :deals, :web_lead, :boolean, default: false
  end
end
