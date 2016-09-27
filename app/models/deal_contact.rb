class DealContact < ActiveRecord::Base
  belongs_to :deal
  belongs_to :contact, required: true

  validates_uniqueness_of :deal_id, scope: [:contact_id]
end
