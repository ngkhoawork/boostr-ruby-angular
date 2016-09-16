class ClientContact < ActiveRecord::Base
  belongs_to :client, counter_cache: :contacts_count
  belongs_to :contact, required: true

  validates_uniqueness_of :client_id, scope: [:contact_id]
end
