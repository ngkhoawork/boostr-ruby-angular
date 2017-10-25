class DealContact < ActiveRecord::Base
  belongs_to :deal
  belongs_to :contact, required: true
  has_one :address, through: :contact

  validates_with BillingContactValidator

  validates_uniqueness_of :deal_id, scope: [:contact_id]
  validates_uniqueness_of :role, scope: [:deal_id], message: 'Only one billing contact allowed', if: Proc.new { |contact| contact.role == 'Billing' }
end
