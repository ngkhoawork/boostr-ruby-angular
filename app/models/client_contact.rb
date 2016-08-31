class ClientContact < ActiveRecord::Base
  belongs_to :client, counter_cache: :contacts_count
  belongs_to :contact, required: true
end
