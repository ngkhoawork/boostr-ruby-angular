class ClientContact < ActiveRecord::Base
  belongs_to :client, counter_cache: :contacts_count, required: true
  belongs_to :contact, required: true
end
