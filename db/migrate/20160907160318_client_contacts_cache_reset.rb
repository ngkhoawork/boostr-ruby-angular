class ClientContactsCacheReset < ActiveRecord::Migration
  def change
    Client.find_each { |client| Client.reset_counters(client.id, :client_contacts) }
  end
end
