class AddCountersToClients < ActiveRecord::Migration
  def change
    add_column :clients, :advertiser_deals_count, :integer, default: 0, null: false
    add_column :clients, :agency_deals_count, :integer, default: 0, null: false
    add_column :clients, :contacts_count, :integer, default: 0, null: false

    Client.find_each do |client|
      Client.reset_counters client.id, :contacts
      Client.reset_counters client.id, :agency_deals
      Client.reset_counters client.id, :advertiser_deals
    end
  end
end
