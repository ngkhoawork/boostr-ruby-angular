class DealContact < ActiveRecord::Base
  belongs_to :deal, counter_cache: :contacts_count
  belongs_to :contact, required: true

  validates_uniqueness_of :deal_id, scope: [:contact_id]
end
