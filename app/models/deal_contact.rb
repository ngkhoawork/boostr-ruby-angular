class DealContact < ActiveRecord::Base
  belongs_to :deal
  belongs_to :contact, required: true

  validates_uniqueness_of :deal_id, scope: [:contact_id]
  validate :billing_contact_address

  private

  def billing_contact_address
    if role && role == 'Billing'
      unless contact.address.street1.presence && contact.address.city.presence && contact.address.zip.presence && contact.address.country.presence
        errors.add(:role, "Billing contact requires street, city, country and postal code")
      end
    end
  end
end
